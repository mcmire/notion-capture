module Specs
  module Matchers
    def be_a_git_tree(blob_entries)
      BeAGitTreeMatcher.new(blob_entries)
    end

    class BeAGitTreeMatcher
      include RSpec::Matchers
      include RSpec::Matchers::Composable

      def initialize(expected_blob_entries)
        @expected_blob_entries = expected_blob_entries
      end

      def matches?(rugged_tree)
        @rugged_tree = rugged_tree
        values_match?(expected_blob_entries, actual_blob_entries)
      end

      def failure_message
        'Expected Rugged tree to have specific set of blobs, ' +
          "but actual set of blobs differed.\n\nDiff:" +
          RSpec::Expectations.differ.diff(
            actual_blob_entries,
            expected_blob_entries,
          )
      end

      private

      attr_reader :expected_blob_entries, :rugged_tree

      def actual_blob_entries
        @actual_blob_entries ||=
          rugged_tree
            .walk(:preorder)
            .inject([]) do |array, (root, entry)|
              if entry[:type] == :blob
                raw_content = rugged_tree.repo.lookup(entry[:oid]).content
                content =
                  begin
                    JSON.parse(raw_content)
                  rescue JSON::ParserError
                    raw_content
                  end
                array + [
                  {
                    name: entry[:name],
                    path: root + entry[:name],
                    content: content,
                  },
                ]
              else
                array
              end
            end
      end
    end
  end
end
