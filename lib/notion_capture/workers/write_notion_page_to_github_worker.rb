require 'json'

require_relative '../github_repo_factory'
require_relative '../notion_client'
require_relative '../notion_page'
require_relative '../sidekiq-hierarchy'

module NotionCapture
  module Workers
    class WriteNotionPageToGithubWorker
      include Sidekiq::Worker

      def perform(notion_page_id)
        @notion_page_id = notion_page_id
        github_repo.write_and_add(file_path, JSON.generate(notion_page.content))
      end

      private

      attr_reader :notion_page_id

      def file_path
        @file_path ||= "#{notion_page.path}.json"
      end

      def notion_page
        @notion_page ||= NotionPage.new(notion_page_data, notion_page_ancestry)
      end

      def notion_page_data
        @notion_page_data ||= notion_client.fetch_complete_page!(notion_page_id)
      end

      def notion_page_ancestry
        @notion_page_ancestry ||=
          notion_client.fetch_page_ancestry!(notion_page_id)
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
