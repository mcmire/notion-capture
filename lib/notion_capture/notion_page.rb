module NotionCapture
  class NotionPage
    attr_reader :id, :content, :raw_content

    def initialize(id:, content:, ancestry:)
      @id = id
      @content = content
      @raw_content = JSON.generate(content)
      @ancestry = ancestry
    end

    def breadcrumbs
      ancestry.reverse
    end

    def last_edited_time
      data.fetch('last_edited_time')
    end

    def child_page_ids
      data
        .fetch('content', [])
        .inject([]) do |child_page_ids, block_id|
          block = blocks_by_id.fetch(block_id)

          if block.fetch('value').fetch('type') == 'page'
            child_page_ids + [block_id]
          else
            child_page_ids
          end
        end
    end

    private

    attr_reader :ancestry

    def data
      @data ||= blocks_by_id.fetch(id).fetch('value')
    end

    def blocks_by_id
      @blocks_by_id ||= content.fetch('block')
    end
  end
end
