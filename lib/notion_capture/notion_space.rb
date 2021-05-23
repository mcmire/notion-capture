require_relative 'notion_client'

module NotionCapture
  class NotionSpace
    def initialize(data)
      @data = data
    end

    def id
      data.fetch('value').fetch('id')
    end

    def root_page_ids
      data.fetch('value').fetch('pages')
    end

    private

    attr_reader :data
  end
end
