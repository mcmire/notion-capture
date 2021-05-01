require "faraday"

module NotionCapture
  class NotionClient
    BASE_URL = "https://www.notion.so/api/v3"
    TOKEN = ENV.fetch("NOTION_TOKEN")
    USER_ID = ENV.fetch("NOTION_USER_ID")

    attr_reader :user_id

    def initialize
      @faraday = Faraday.new(
        url: BASE_URL,
        headers: { "Cookie" => "token_v2=#{TOKEN}" }
      )
      @user_id = USER_ID
    end

    def fetch_spaces!
      response = faraday.post("/getSpaces")

      if response.success?
        response
      else
        raise FailedRequestError.new(
          "Could not retrieve Notion spaces. Response body:\n\n" + response.body
        )
      end
    end

    def fetch_complete_page!(page_id)
      record_map = {}
      cursor = { stack: [] }
      chunk_number = 0

      loop do
        response = fetch_single_page_chunk!(
          page_id,
          cursor: cursor,
          chunk_number: chunk_number
        )
        deep_merge_into!(record_map, response.body.fetch("recordMap"))
        cursor.merge!(response.body.fetch("cursor"))
        chunk_number += 1

        if response.body.fetch("cursor").fetch("stack").empty?
          break
        end
      end

      record_map
    end

    private

    attr_reader :faraday

    class FailedRequestError < StandardError; end

    def fetch_single_page_chunk!(
      page_id,
      cursor: { stack: [] },
      chunk_number: 0
    )
      response = faraday.post(
        "/loadPageChunk",
        body: {
          pageId: page_id,
          limit: 30,
          cursor: cursor,
          chunkNumber: chunkNumber,
          verticalColumns: false
        }
      )

      if response.success?
        response
      else
        raise FailedRequestError.new(
          "Could not fetch Notion page. Response body:\n\n" + response.body
        )
      end
    end

    def deep_merge_into!(target_hash, source_hash)
      source_hash.each do |key, value|
        # just go one level deep
        if target_hash[key].is_a?(Hash)
          target_hash[key].merge!(value)
        else
          raise ArgumentError.new(
            "target_hash[#{key.inspect}] is a #{target_hash[key].class} and " +
            "I don't know what to do with that"
          )
        end
      end
    end
  end
end
