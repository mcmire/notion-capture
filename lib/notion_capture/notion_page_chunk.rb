require 'json'

module NotionCapture
  class NotionPageChunk
    def self.collection_view_id_tuples_for(block)
      value = block.fetch('value')

      if value.include?('collection_id')
        collection_id = value.fetch('collection_id')
        collection_view_ids = value.fetch('view_ids')
        collection_view_ids.map do |collection_view_id|
          {
            collection_id: collection_id,
            collection_view_id: collection_view_id,
          }
        end
      else
        []
      end
    end

    attr_reader(:id, :request_data, :raw_request_data, :lineage, :space_id)

    def initialize(id:, request_data:, lineage:, space_id:)
      @id = id
      @request_data = request_data
      @raw_request_data = JSON.generate(request_data)
      @lineage = lineage
      @space_id = space_id
    end

    def file_path
      [
        'spaces',
        space_id,
        *lineage.reverse.flat_map { |page_id| ['pages', page_id] },
      ].join('/') + '.json'
    end

    def type
      data.fetch('type')
    end

    def title
      properties ? properties.fetch('title').flatten.first : nil
    end

    def collection_name
      collections_by_id
        .fetch(data.fetch('collection_id'))
        .fetch('value')
        .fetch('name')
        .flatten
        .first
    end

    def updated_at
      Time.at(data.fetch('last_edited_time').to_f / 1000)
    end

    def child_page_chunk_ids
      data
        .fetch('content', [])
        .inject([]) do |ids, id|
          block = blocks_by_id.fetch(id)

          block.fetch('value').fetch('type') == 'page' ? ids + [id] : ids
        end
    end

    def collection_view_id_tuples
      direct_collection_view_id_tuples + child_collection_view_id_tuples
    end

    private

    def direct_collection_view_id_tuples
      self.class.collection_view_id_tuples_for(block)
    end

    def child_collection_view_id_tuples
      data
        .fetch('content', [])
        .inject([]) do |ids, id|
          block = blocks_by_id.fetch(id)

          if block.fetch('value').fetch('type') == 'collection_view'
            ids + self.class.collection_view_id_tuples_for(block)
          else
            ids
          end
        end
    end

    def properties
      data['properties']
    end

    def data
      @data ||= block.fetch('value')
    end

    def block
      @block ||= blocks_by_id.fetch(id)
    end

    def blocks_by_id
      @blocks_by_id ||= request_data.fetch('block')
    end

    def collections_by_id
      @collections_by_id ||= request_data.fetch('collection')
    end
  end
end
