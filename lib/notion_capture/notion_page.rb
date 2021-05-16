module NotionCapture
  class NotionPage
    attr_reader :content

    def initialize(content, ancestry)
      @content = content
      @ancestry = ancestry
    end

    def path
      ancestry.reverse.join('/')
    end

    private

    attr_reader :ancestry
  end
end
