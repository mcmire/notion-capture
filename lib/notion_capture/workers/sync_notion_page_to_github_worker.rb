require_relative '../git_repo_factory'
require_relative '../notion_client'
require_relative '../notion_page'

module NotionCapture
  module Workers
    class SyncNotionPageToGithubWorker
      include Sidekiq::Worker

      def perform(notion_page_id, notion_space_id)
        @notion_page_id = notion_page_id
        @notion_space_id = notion_space_id

        git_repo_factory.with_exclusive_repo do |git_repo|
          @git_repo = git_repo

          if should_save_notion_page?
            git_repo.push_file!(
              page_file_path,
              JSON.pretty_generate(fresh_notion_page.content),
            )
          end
        end

        fresh_notion_page.child_page_ids.each do |child_notion_page_id|
          self.class.perform_async(child_notion_page_id, notion_space_id)
        end
      end

      private

      attr_reader :notion_page_id, :notion_space_id, :git_repo

      def git_repo_factory
        @git_repo_factory ||=
          GitRepoFactory.new(
            remote_url: NotionCapture.configuration.remote_repo_url,
            local_directory: NotionCapture.configuration.local_repo_dir,
            lockfile_path: NotionCapture.configuration.lockfile_path,
          )
      end

      def should_save_notion_page?
        !saved_notion_page ||
          fresh_notion_page.last_edited_time >
            saved_notion_page.last_edited_time
      end

      def saved_notion_page
        @saved_notion_page ||=
          if file = git_repo.find_file!(page_file_path)
            NotionPage.new(
              id: notion_page_id,
              content: JSON.parse(file.content),
              ancestry: File.basename(file.path, '.json').split('/').reverse,
            )
          end
      end

      def page_file_path
        [
          'spaces',
          notion_space_id,
          'pages',
          "#{fresh_notion_page.breadcrumbs.join('/')}.json",
        ].join('/')
      end

      def fresh_notion_page
        @fresh_notion_page ||=
          NotionPage.new(
            id: notion_page_id,
            content: notion_client.fetch_complete_page!(notion_page_id),
            ancestry: notion_client.fetch_page_ancestry!(notion_page_id),
          )
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end
    end
  end
end
