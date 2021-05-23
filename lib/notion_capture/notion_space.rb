require_relative 'notion_client'

module NotionCapture
  class NotionSpace
    attr_reader :id

    def initialize(id, data)
      @id = id
      @data = data
    end

    def root_page_ids
      data.fetch('value').fetch('pages')
    end

    private

    attr_reader :data
  end
end
