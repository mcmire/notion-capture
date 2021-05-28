require 'sidekiq'

require_relative '../notion'
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
          Notion
            .client
            .fetch_spaces!
            .fetch(Notion::USER_ID)
            .fetch('space')
            .map { |space_id, data| NotionSpace.new(space_id, data) }
      end
    end
  end
end
