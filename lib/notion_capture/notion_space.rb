require_relative 'notion_client'
require_relative 'page_summary'

module NotionCapture
  class NotionSpace
    def initialize(notion_client)
      @notion_client = notion_client
    end

    def page_summaries_by_id
      data
        .fetch(notion_client.user_id)
        .fetch('block')
        .values
        .map(&PageSummary.method(:from_notion_block))
        .inject({}) do |hash, page_summary|
          hash.merge(page_summary.id => page_summary)
        end
    end

    private

    attr_reader :notion_client

    def data
      notion_client.fetch_spaces!
    end
  end
end
