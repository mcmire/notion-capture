require "logger"
require "http"

module NotionCapture
  class NotionClient
    BASE_URL = "https://www.notion.so/api/v3"

    def self.debug!
      self.logger = Logger.new(STDOUT)
    end

    singleton_class.attr_accessor :logger
    self.logger = Logger.new("/dev/null")

    def initialize
      @http = HTTP
        .use(logging: { logger: self.class.logger })
        .headers(
          "Accept" => "application/json",
          "Cookie" => "token_v2=#{token}"
        )
    end

    def user_id
      @user_id ||= ENV.fetch("NOTION_USER_ID") do
        raise ConfigurationError.new(
          "NOTION_USER_ID is missing.\n" +
          "Do you have an .env file and if so does it contain this variable?"
        )
      end
    end

    def fetch_spaces!
      make_request!(:post, "/getSpaces")
    end

    def fetch_complete_page!(page_id)
      record_map = {}
      cursor = { "stack" => [] }
      chunk_number = 0

      loop do
        json = fetch_single_page_chunk!(
          page_id,
          cursor: cursor,
          chunk_number: chunk_number
        )
        deep_merge_into!(record_map, json.fetch("recordMap"))
        cursor.merge!(json.fetch("cursor"))
        chunk_number += 1

        if json.fetch("cursor").fetch("stack").empty?
          break
        end
      end

      {
        "recordMap" => record_map,
        "cursor" => { "stack" => [] }
      }
    end

    private

    attr_reader :http

    def token
      @token ||= ENV.fetch("NOTION_TOKEN") do
        raise ConfigurationError.new(
          "NOTION_TOKEN is missing.\n" +
          "Do you have an .env file and if so does it contain this variable?"
        )
      end
    end

    def fetch_single_page_chunk!(
      page_id,
      cursor: { stack: [] },
      chunk_number: 0
    )
      make_request!(
        :post,
        "/loadPageChunk",
        json: {
          pageId: page_id,
          limit: 30,
          cursor: cursor,
          chunkNumber: chunk_number,
          verticalColumns: false
        }
      )
    end

    def make_request!(method, path, **options)
      response = http.public_send(method, BASE_URL + path, **options)

      if response.status.success?
        response.parse
      else
        raise FailedRequestError.new(
          "#{method.upcase} #{path} failed with #{response.status.code}. " +
          "Response body:\n\n" + response.body
        )
      end
    end

    def deep_merge_into!(target_hash, source_hash)
      source_hash.each do |key, value|
        # just go one level deep
        if target_hash[key].is_a?(Hash)
          target_hash[key].merge!(value)
        elsif target_hash[key]
          raise ArgumentError.new(
            "target_hash[#{key.inspect}] is a #{target_hash[key].class} and " +
            "I don't know what to do with that"
          )
        else
          target_hash[key] = value
        end
      end
    end

    class ConfigurationError < StandardError; end
    class FailedRequestError < StandardError; end
  end
end
