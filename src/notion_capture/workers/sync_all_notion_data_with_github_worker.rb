require "sidekiq"

require_relative "fetch_indexed_github_page_summaries"
require_relative "fetch_indexed_notion_page_summaries"
require_relative "github_repo"
require_relative "write_notion_page_to_github_worker"

module NotionCapture
  module Workers
    class SyncAllNotionDataWithGithubWorker
      include Sidekiq::Worker

      def perform
        notion_page_summaries_by_id.each do |notion_page_id, notion_page_summary|
          github_page_summary = github_page_summaries_by_id[notion_page_id]

          if should_write_notion_page?(notion_page_summary, github_page_summary)
            WriteNotionPageToGithubWorker.new.perform(notion_page_id)
          end
        end
      end

      private

      def should_write_notion_page?(notion_page_summary, github_page_summary)
        !github_page_summary ||
          notion_page_summary.last_edited_time > github_page_summary.last_edited_time
      end

      def notion_page_summaries_by_id
        @notion_page_summaries_by_id ||= notion_space.page_summaries_by_id
      end

      def github_page_summaries_by_id
        @github_page_summaries_by_id ||= github_repo.page_summaries_by_id
      end

      def notion_space
        @notion_space ||= NotionSpace.new
      end

      def github_repo
        @github_repo ||= GithubRepoFactory.instance.fresh_or_updated
      end
    end
  end
end
