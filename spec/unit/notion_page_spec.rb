RSpec.describe NotionCapture::NotionPage do
  describe '#child_page_ids' do
    it "returns the ids of the page's child page blocks" do
      notion_page =
        described_class.new(
          id: '12ba1ded-9372-45a3-adc9-ce985053d7a8',
          content: {
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
          ancestry: nil,
        )

      expect(notion_page.child_page_ids).to eq(
        %w[
          d0bc03ce-e9c0-467e-8bba-e9814399c423
          722ba1ef-e17a-4175-90c6-dd123ddf11d4
        ],
      )
    end
  end
end
