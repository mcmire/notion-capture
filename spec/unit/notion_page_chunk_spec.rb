RSpec.describe NotionCapture::NotionPageChunk do
  describe '#file_path' do
    it 'returns the path of the file version of the page chunk, based on the lineage' do
      notion_page_chunk =
        described_class.new(
          id: '9cee1f86-c21c-49df-ab05-af524d084b1a',
          request_data: nil,
          lineage: %w[
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
          9cee1f86-c21c-49df-ab05-af524d084b1a.json
        ].join('/'),
      )
    end
  end

  describe '#title' do
    it 'returns the title of the page from its properties' do
      notion_page_chunk =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          request_data: {
            'block' => {
              '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                'value' => {
                  'properties' => {
                    'title' => [['Some kind of page']],
                  },
                },
              },
            },
          },
          lineage: nil,
          space_id: nil,
        )

      expect(notion_page_chunk.title).to eq('Some kind of page')
    end
  end

  describe '#updated_at' do
    it 'returns the time the page was last updated from last_edited_time, as a Time' do
      notion_page_chunk =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          request_data: {
            'block' => {
              '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                'value' => {
                  'last_edited_time' => 1_621_816_980_000,
                },
              },
            },
          },
          lineage: nil,
          space_id: nil,
        )

      expect(notion_page_chunk.updated_at).to eq(
        Time.local(2021, 5, 23, 18, 43),
      )
    end
  end

  describe '#child_page_chunk_ids' do
    context 'assuming that the page has a "content" key' do
      it "returns the ids of the page's child page blocks" do
        notion_page_chunk =
          described_class.new(
            id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
            request_data: {
              'block' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {
                    'type' => 'page',
                    'content' => %w[
                      9cee1f86-c21c-49df-ab05-af524d084b1a
                      d0bc03ce-e9c0-467e-8bba-e9814399c423
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    ],
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
                  },
                },
                '722ba1ef-e17a-4175-90c6-dd123ddf11d4' => {
                  'value' => {
                    'type' => 'page',
                  },
                },
              },
            },
            lineage: nil,
            space_id: nil,
          )

        expect(notion_page_chunk.child_page_chunk_ids).to eq(
          %w[
            d0bc03ce-e9c0-467e-8bba-e9814399c423
            722ba1ef-e17a-4175-90c6-dd123ddf11d4
          ],
        )
      end
    end

    context 'if the page does not have a "content" key' do
      it 'returns an empty array' do
        notion_page_chunk =
          described_class.new(
            id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
            request_data: {
              'block' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {},
                },
              },
            },
            lineage: nil,
            space_id: nil,
          )

        expect(notion_page_chunk.child_page_chunk_ids).to eq([])
      end
    end
  end

  describe '#collection_view_id_tuples' do
    context 'if the block has a "content" key (as in a page block)' do
      it "returns an array of (collection_view_id, collection_id) derived from the page's collection_view blocks" do
        notion_page_chunk =
          described_class.new(
            id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
            request_data: {
              'block' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {
                    'type' => 'page',
                    'content' => %w[
                      227fd83a-546c-48f2-abde-14a08c43faae
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    ],
                  },
                },
                '227fd83a-546c-48f2-abde-14a08c43faae' => {
                  'value' => {
                    'type' => 'collection_view',
                    'collection_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                    'view_ids' => %w[
                      ce55eba9-ab50-4f33-ac0d-df6ba7132973
                      80482a7b-195b-4665-82f1-0a7825e77476
                    ],
                  },
                },
                '0ecc4427-3c80-4b97-9e70-9f35ac4c5405' => {
                  'value' => {
                    'type' => 'collection_view',
                    'collection_id' => '2644cda5-4619-4aed-9959-da51754a758b',
                    'view_ids' => ['0ecc4427-3c80-4b97-9e70-9f35ac4c5405'],
                  },
                },
              },
            },
            lineage: nil,
            space_id: nil,
          )

        expect(notion_page_chunk.collection_view_id_tuples).to eq(
          [
            {
              collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
              collection_view_id: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
            },
            {
              collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
              collection_view_id: '80482a7b-195b-4665-82f1-0a7825e77476',
            },
            {
              collection_id: '2644cda5-4619-4aed-9959-da51754a758b',
              collection_view_id: '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
            },
          ],
        )
      end
    end

    context 'if the block does not have a "content" key (as in a collection view block)' do
      it "returns an array of (collection_view_id, collection_id) derived from the page's view_ids" do
        notion_page_chunk =
          described_class.new(
            id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
            request_data: {
              'block' => {
                '12ba1ded-9372-45a3-adc9-ce985053d7a8' => {
                  'value' => {
                    'collection_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                    'view_ids' => %w[
                      ce55eba9-ab50-4f33-ac0d-df6ba7132973
                      80482a7b-195b-4665-82f1-0a7825e77476
                    ],
                  },
                },
              },
            },
            lineage: nil,
            space_id: nil,
          )

        expect(notion_page_chunk.collection_view_id_tuples).to eq(
          [
            {
              collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
              collection_view_id: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
            },
            {
              collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
              collection_view_id: '80482a7b-195b-4665-82f1-0a7825e77476',
            },
          ],
        )
      end
    end
  end
end
