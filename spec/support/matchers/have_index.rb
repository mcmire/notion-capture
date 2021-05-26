module Specs
  module Matchers
    def have_index(expected_index_entries)
      HaveIndexMatcher.new(expected_index_entries)
    end

    class HaveIndexMatcher
      include RSpec::Matchers
      include RSpec::Matchers::Composable

      def initialize(expected_index_entries)
        @expected_index_entries =
          an_array_matching(
            expected_index_entries.map { |entry| a_hash_including(entry) },
          )
      end

      def matches?(rugged_repo)
        @rugged_repo = rugged_repo
        values_match?(expected_index_entries, actual_index_entries)
      end

      def failure_message
        'Expected Rugged repo to have index with specific set of entries, ' +
          "but actual set of entries differed.\n\nDiff:" +
          RSpec::Expectations.differ.diff(
            actual_index_entries,
            expected_index_entries,
          )
      end

      private

      attr_reader :expected_index_entries, :rugged_repo

      def actual_index_entries
        @actual_index_entries ||=
          rugged_repo
            .index
            .to_a
            .map do |entry|
              {
                path: entry[:path],
                oid: entry[:oid],
                content: rugged_repo.lookup(entry[:oid]).content,
              }
            end
      end
    end
  end
end
