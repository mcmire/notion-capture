require "json"

module NotionCapture
  class PageSummary
    def self.from_blob(blob)
      json = JSON.parse(blob.content)
      last_edited_time_in_ms = json.fetch("last_edited_time")
      new(
        id: json.fetch("id"),
        last_edited_time: Time.at(last_edited_time_in_ms / 1000)
      )
    end

    def self.from_block(block)
      last_edited_time_in_ms = block.fetch("value").fetch("last_edited_time")
      new(
        id: block.fetch("id"),
        last_edited_time: Time.at(last_edited_time_in_ms / 1000)
      )
    end

    attr_reader :id, :last_edited_time

    def initialize(id:, last_edited_time:)
      @id = id
      @last_edited_time = last_edited_time
    end
  end
end
