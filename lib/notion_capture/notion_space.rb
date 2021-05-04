require_relative "notion_client"
require_relative "page_summary"

module NotionCapture
  class NotionSpace
    def initialize
      @notion_client = NotionClient.new
    end

    def page_summaries_by_id
      data
        .fetch(notion_client.user_id)
        .fetch("block")
        .values
        .map(&PageSummary.method(:from_notion_block))
        .index_by(&:id)
    end

    private

    attr_reader :notion_client

    def data
      notion_client.fetch_spaces!
    end
  end
end
