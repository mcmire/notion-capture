require 'json'

module NotionCapture
  class NotionCollectionView
    attr_reader(
      :id,
      :request_data,
      :raw_request_data,
      :parent_page_lineage,
      :space_id,
    )

    def initialize(id:, request_data:, parent_page_lineage:, space_id:)
      @id = id
      @request_data = request_data
      @raw_request_data = JSON.generate(request_data)
      @parent_page_lineage = parent_page_lineage
      @space_id = space_id
    end

    def file_path
      [
        'data',
        'spaces',
        space_id,
        *parent_page_lineage.reverse.flat_map { |page_id| ['pages', page_id] },
        'collection_views',
        id,
      ].join('/') + '.json'
    end

    def name
      data.fetch('name')
    end

    private

    def breadcrumbs
      lineage.reverse
    end

    def data
      @data ||= collection_views_by_id.fetch(id).fetch('value')
    end

    def collection_views_by_id
      @collection_views_by_id ||= records_by_type.fetch('collection_view')
    end

    def records_by_type
      @records_by_type ||= request_data.fetch('recordMap')
    end
  end
end
