RSpec.describe NotionCapture::NotionCollectionView do
  describe '#file_path' do
    it 'returns the path of the file version of the collection view, based on the parent_page_lineage' do
      notion_page_chunk =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          request_data: nil,
          parent_page_lineage: %w[
            9cee1f86-c21c-49df-ab05-af524d084b1a
            d0bc03ce-e9c0-467e-8bba-e9814399c423
            722ba1ef-e17a-4175-90c6-dd123ddf11d4
          ],
          space_id: '9292b46f-54ab-41db-b39d-17436d8f8f14',
        )

      expect(notion_page_chunk.file_path).to eq(
        %w[
          data
          spaces
          9292b46f-54ab-41db-b39d-17436d8f8f14
          pages
          722ba1ef-e17a-4175-90c6-dd123ddf11d4
          pages
          d0bc03ce-e9c0-467e-8bba-e9814399c423
          pages
          9cee1f86-c21c-49df-ab05-af524d084b1a
          collection_views
          12ba1ded-9372-45a3-adc9-ce985053d7a8.json
        ].join('/'),
      )
    end
  end

  describe '#name' do
    it 'returns the name of the collection view from its data' do
      notion_page_chunk =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          request_data: {
            'recordMap' => {
              'collection_view' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {
                    'name' => 'Some kind of collection view',
                  },
                },
              },
            },
          },
          parent_page_lineage: nil,
          space_id: nil,
        )

      expect(notion_page_chunk.name).to eq('Some kind of collection view')
    end
  end

  describe '#child_page_chunk_ids' do
    it "returns the ids of the collection views's child page blocks" do
      notion_collection_view =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          request_data: {
            'result' => {
              'type' => 'reducer',
              'reducerResults' => {
                'collection_group_results' => {
                  'blockIds' => %w[
                    9cee1f86-c21c-49df-ab05-af524d084b1a
                    d0bc03ce-e9c0-467e-8bba-e9814399c423
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    9254fbf6-9b7d-4772-97f9-60505d75a464
                  ],
                },
              },
            },
            'recordMap' => {
              'block' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {
                    'type' => 'page',
                    'properties' => {
                      'title' => 'something',
                    },
                  },
                },
                '9cee1f86-c21c-49df-ab05-af524d084b1a' => {
                  'value' => {
                    'type' => 'text',
                  },
                },
                'd0bc03ce-e9c0-467e-8bba-e9814399c423' => {
                  'value' => {
                    'type' => 'page',
                    'properties' => {
                      'title' => 'something',
                    },
                  },
                },
                '722ba1ef-e17a-4175-90c6-dd123ddf11d4' => {
                  'value' => {
                    'type' => 'page',
                    'properties' => {
                      'title' => 'something',
                    },
                  },
                },
                '9254fbf6-9b7d-4772-97f9-60505d75a464' => {
                  'value' => {
                    'type' => 'page',
                  },
                },
              },
            },
          },
          parent_page_lineage: nil,
          space_id: nil,
        )

      expect(notion_collection_view.child_page_chunk_ids).to eq(
        %w[
          d0bc03ce-e9c0-467e-8bba-e9814399c423
          722ba1ef-e17a-4175-90c6-dd123ddf11d4
        ],
      )
    end
  end
end
