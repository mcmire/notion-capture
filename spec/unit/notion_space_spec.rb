RSpec.describe NotionCapture::NotionSpace do
  describe '#root_page_ids' do
    it 'returns all page ids under the space' do
      notion_space =
        described_class.new(
          'some-space-id',
          {
            'value' => {
              'pages' => %w[
                e188b9fe-c004-4ea2-b211-dc587d9ef1f4
                427bbb3d-3928-4d1f-bcc0-38f7b02b4777
                7868b070-cf4d-460e-ae6b-3c407527f7fe
              ],
            },
          },
        )

      expect(notion_space.root_page_ids).to(
        match_array(
          %w[
            e188b9fe-c004-4ea2-b211-dc587d9ef1f4
            427bbb3d-3928-4d1f-bcc0-38f7b02b4777
            7868b070-cf4d-460e-ae6b-3c407527f7fe
          ],
        ),
      )
    end
  end
end
