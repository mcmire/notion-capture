require_relative '../git_repo_factory'
require_relative '../notion_client'
require_relative '../notion_collection_view'

module NotionCapture
  module Workers
    class SyncNotionCollectionViewToGithubWorker
      include Sidekiq::Worker

      def perform(
        notion_collection_view_id,
        notion_collection_id,
        parent_page_lineage,
        notion_space_id
      )
        @notion_collection_view_id = notion_collection_view_id
        @notion_collection_id = notion_collection_id
        @parent_page_lineage = parent_page_lineage
        @notion_space_id = notion_space_id

        git_repo_factory.with_exclusive_repo do |git_repo|
          @git_repo = git_repo

          if should_save_notion_collection_view?
            git_repo.pushing_commit!(
              "Sync collection view #{fresh_notion_collection_view.id}",
            ) do
              git_repo.create_file_in_index!(
                fresh_notion_collection_view.file_path,
                JSON.pretty_generate(fresh_notion_collection_view.request_data),
              )
            end
          end
        end
      end

      private

      attr_reader(
        :notion_collection_view_id,
        :notion_collection_id,
        :parent_page_lineage,
        :notion_space_id,
        :git_repo,
      )

      def git_repo_factory
        @git_repo_factory ||=
          GitRepoFactory.new(
            remote_url: NotionCapture.configuration.remote_repo_url,
            local_directory: NotionCapture.configuration.local_repo_dir,
            lockfile_path: NotionCapture.configuration.lockfile_path,
          )
      end

      def should_save_notion_collection_view?
        !saved_notion_collection_view ||
          fresh_notion_collection_view.request_data !=
            saved_notion_collection_view.request_data
      end

      def saved_notion_collection_view
        @saved_notion_collection_view ||=
          if file = git_repo.find_file!(fresh_notion_collection_view.file_path)
            NotionCollectionView.new(
              id: fresh_notion_collection_view.id,
              request_data: JSON.parse(file.content),
              parent_page_lineage:
                fresh_notion_collection_view.parent_page_lineage,
              space_id: fresh_notion_collection_view.space_id,
            )
          end
      end

      def fresh_notion_collection_view
        @fresh_notion_collection_view ||=
          NotionCollectionView.new(
            id: notion_collection_view_id,
            request_data:
              notion_client.fetch_collection_view!(
                id: notion_collection_view_id,
                collection_id: notion_collection_id,
              ),
            parent_page_lineage: parent_page_lineage,
            space_id: notion_space_id,
          )
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end
    end
  end
end
