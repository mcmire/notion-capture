module NotionCapture
  module Notion
    class Client
      def self.deep_merge_into!(target_hash, source_hash)
        source_hash.each do |key, value|
          # just go one level deep
          if target_hash[key].is_a?(Hash)
            target_hash[key].merge!(value)
          elsif target_hash[key]
            raise(
              ArgumentError.new(
                "target_hash[#{key.inspect}] is a #{target_hash[key].class} and " +
                  "I don't know what to do with that",
              ),
            )
          else
            target_hash[key] = value
          end
        end
      end

      def initialize(authenticator)
        @authenticator = authenticator
      end

      def fetch_spaces!
        Requestor.call(
          verb: :post,
          path: '/getSpaces',
          authenticator: authenticator,
        )
      end

      def fetch_complete_page!(page_id)
        record_map = {}
        cursor = { 'stack' => [] }
        chunk_number = 0

        loop do
          json =
            fetch_single_page_chunk!(
              page_id,
              cursor: cursor,
              chunk_number: chunk_number,
            )

          self.class.deep_merge_into!(record_map, json.fetch('recordMap'))
          cursor.merge!(json.fetch('cursor'))
          chunk_number += 1

          break if json.fetch('cursor').fetch('stack').empty?
        end

        record_map
      end

      def fetch_page_lineage!(page_id)
        json =
          Requestor.call(
            verb: :post,
            path: '/getBacklinksForBlock',
            options: {
              json: {
                blockId: page_id,
              },
            },
            authenticator: authenticator,
          )

        json
          .fetch('recordMap')
          .fetch('block')
          .inject([]) do |array, (id, block)|
            value = block.fetch('value')
            parent_table = value.fetch('parent_table')
            parent_id = value.fetch('parent_id')

            if parent_table == 'block' && (index = array.find_index(parent_id))
              array[0..index - 1] + [id] + array[index..-1]
            else
              array + [id]
            end
          end
      end

      def fetch_collection_view!(id:, collection_id:)
        Requestor.call(
          verb: :post,
          path: '/queryCollection',
          options: {
            json: {
              collectionId: collection_id,
              collectionViewId: id,
              query: {},
              loader: {
                type: 'reducer',
                reducers: {
                  collection_group_results: {
                    type: 'results',
                    limit: 50,
                  },
                },
                searchQuery: '',
                userTimeZone: 'America/Denver',
              },
            },
          },
          authenticator: authenticator,
        )
      end

      private

      attr_reader :authenticator

      def fetch_single_page_chunk!(
        page_id,
        cursor: { stack: [] },
        chunk_number: 0
      )
        Requestor.call(
          verb: :post,
          path: '/loadPageChunk',
          options: {
            json: {
              pageId: page_id,
              limit: 30,
              cursor: cursor,
              chunkNumber: chunk_number,
              verticalColumns: false,
            },
          },
          authenticator: authenticator,
        )
      end
    end
  end
end
