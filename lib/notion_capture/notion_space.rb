require_relative 'notion_client'
require_relative 'page_summary'

module NotionCapture
  class NotionSpace
    def initialize(notion_client)
      @notion_client = notion_client
    end

    def root_page_ids
      notion_client
        .fetch_spaces!
        .fetch(notion_client.user_id)
        .fetch('block')
        .keys
    end

    private

    attr_reader :notion_client
  end
end
