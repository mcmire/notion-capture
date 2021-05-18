require_relative '../github_repo_factory'
require_relative '../notion_space'
require_relative '../sidekiq-hierarchy'
require_relative 'write_notion_page_to_github_worker'
require_relative 'persist_github_repo_worker'

module NotionCapture
  module Workers
    class SyncAllNotionDataWithGithubWorker
      include Sidekiq::Worker

      # sidekiq_options workflow: true

      def perform
        notion_page_summaries_by_id
          .each do |notion_page_id, notion_page_summary|
          github_page_summary = github_page_summaries_by_id[notion_page_id]

          if should_write_notion_page?(notion_page_summary, github_page_summary)
            WriteNotionPageToGithubWorker.new.perform(notion_page_id)
          end
        end

        PersistGithubRepoWorker.new.perform
      end

      private

      def should_write_notion_page?(notion_page_summary, github_page_summary)
        !github_page_summary ||
          notion_page_summary.last_edited_time >
            github_page_summary.last_edited_time
      end

      def notion_page_summaries_by_id
        @notion_page_summaries_by_id ||= notion_space.page_summaries_by_id
      end

      def github_page_summaries_by_id
        @github_page_summaries_by_id ||= github_repo.page_summaries_by_id
      end

      def notion_space
        @notion_space ||= NotionSpace.new(notion_client)
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end

      def github_repo
        @github_repo ||= NotionCapture.github_repo_factory.fresh_or_updated
      end
    end
  end
end
