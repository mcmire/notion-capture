require 'sidekiq'

require_relative '../notion_client'
require_relative '../notion_space'
require_relative 'sync_notion_page_chunk_to_github_worker'

module NotionCapture
  module Workers
    class SyncAllNotionDataWithGithubWorker
      include Sidekiq::Worker

      def perform
        notion_spaces.each do |notion_space|
          notion_space.root_page_ids.each do |notion_page_id|
            SyncNotionPageChunkToGithubWorker.perform_async(
              notion_page_id,
              notion_space.id,
            )
          end
        end
      end

      private

      def notion_spaces
        @notion_spaces ||=
          notion_client
            .fetch_spaces!
            .fetch(notion_client.user_id)
            .fetch('space')
            .map { |space_id, data| NotionSpace.new(space_id, data) }
      end

      def notion_client
        @notion_client ||= NotionClient.new
      end
    end
  end
end
