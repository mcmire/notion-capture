module Specs
  module Matchers
    def be_a_json_blob_including(expected_partial_hash)
      BeAJsonBlobIncludingMatcher.new(expected_partial_hash)
    end

    alias_matcher :a_json_blob_including, :be_a_json_blob_including

    class BeAJsonBlobIncludingMatcher
      include RSpec::Matchers
      include RSpec::Matchers::Composable

      def initialize(expected_partial_hash)
        @expected_partial_hash = a_hash_including(expected_partial_hash)
      end

      def description
        "be a JSON blob"
      end

      def matches?(actual_json)
        @actual_json = actual_json
        !actual_parsed_json.nil? && values_match?(expected_partial_hash, actual_parsed_json)
      end

      def failure_message
        if actual_parsed_json
          "Expected value to be a JSON blob matching #{expected_partial_hash.inspect},\nbut got #{actual_json}."
        else
          "Expected value to be JSON, but was not."
        end
      end

      private

      attr_reader :expected_partial_hash, :actual_json

      def actual_parsed_json
        if defined?(@parsed_json)
          @parsed_json
        else
          begin
            @parsed_json = JSON.parse(actual_json)
          rescue JSON::ParseError

            @parsed_json = nil
          end
        end
      end
    end
  end
end
