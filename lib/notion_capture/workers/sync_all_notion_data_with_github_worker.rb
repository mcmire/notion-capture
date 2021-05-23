require 'sidekiq'

require_relative '../notion_space'
require_relative 'sync_notion_page_to_github_worker'

module NotionCapture
  module Workers
    class SyncAllNotionDataWithGithubWorker
      include Sidekiq::Worker

      def perform
        notion_space.root_page_ids.each do |notion_page_id|
          SyncNotionPageToGithubWorker.perform_async(
            notion_page_id,
            notion_space.id,
          )
        end
      end

      private

      def notion_space
        @notion_space ||=
          NotionSpace.new(
            notion_client
              .fetch_spaces!
              .fetch(notion_client.user_id)
              .fetch('space')
              .values
              .first,
          )
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end
    end
  end
end
