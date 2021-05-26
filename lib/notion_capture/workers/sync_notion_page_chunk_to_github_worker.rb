require_relative '../git_repo_factory'
require_relative '../notion_client'
require_relative '../notion_page_chunk'
require_relative 'sync_notion_collection_view_to_github_worker'

module NotionCapture
  module Workers
    class SyncNotionPageChunkToGithubWorker
      include Sidekiq::Worker

      def perform(notion_block_id, notion_space_id)
        @notion_block_id = notion_block_id
        @notion_space_id = notion_space_id

        git_repo_factory.with_exclusive_repo do |git_repo|
          @git_repo = git_repo

          if should_save_notion_page?
            commit_message =
              if fresh_notion_page_chunk.type == 'collection_view_page'
                "Sync collection view page \"#{fresh_notion_page_chunk.collection_name}\""
              else
                "Sync page \"#{fresh_notion_page_chunk.title}\""
              end

            git_repo.pushing_commit!(commit_message) do
              git_repo.create_file_in_index!(
                fresh_notion_page_chunk.file_path,
                JSON.pretty_generate(fresh_notion_page_chunk.request_data),
              )
            end
          end
        end

        fresh_notion_page_chunk.child_page_chunk_ids.each do |id|
          self.class.perform_async(id, notion_space_id)
        end

        fresh_notion_page_chunk.collection_view_id_tuples.each do |tuple|
          SyncNotionCollectionViewToGithubWorker.perform_async(
            tuple[:collection_view_id],
            tuple[:collection_id],
            fresh_notion_page_chunk.lineage,
            notion_space_id,
          )
        end
      end

      private

      attr_reader :notion_block_id, :notion_space_id, :git_repo

      def git_repo_factory
        @git_repo_factory ||=
          GitRepoFactory.new(
            remote_url: NotionCapture.configuration.remote_repo_url,
            local_directory: NotionCapture.configuration.local_repo_dir,
            lockfile_path: NotionCapture.configuration.lockfile_path,
          )
      end

      def should_save_notion_page?
        !saved_notion_page_chunk ||
          fresh_notion_page_chunk.request_data !=
            saved_notion_page_chunk.request_data
      end

      def saved_notion_page_chunk
        @saved_notion_page_chunk ||=
          if file = git_repo.find_file!(fresh_notion_page_chunk.file_path)
            NotionPageChunk.new(
              id: fresh_notion_page_chunk.id,
              request_data: JSON.parse(file.content),
              lineage: fresh_notion_page_chunk.lineage,
              space_id: fresh_notion_page_chunk.space_id,
            )
          end
      end

      def fresh_notion_page_chunk
        @fresh_notion_page_chunk ||=
          NotionPageChunk.new(
            id: notion_block_id,
            request_data: notion_client.fetch_complete_page!(notion_block_id),
            lineage: notion_client.fetch_page_lineage!(notion_block_id),
            space_id: notion_space_id,
          )
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end
    end
  end
end
