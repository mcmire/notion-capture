RSpec.describe NotionCapture::NotionSpace do
  describe '#page_summaries_by_id' do
    it 'returns all pages under the space as a hash of Notion page id => PageSummary' do
      notion_client =
        double(
          :notion_client,
          user_id: 'some-user-id',
          fetch_spaces!: {
            'some-user-id' => {
              'block' => {
                'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' => {
                  'value' => {
                    'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                    'last_edited_time' => 1_620_017_167_711,
                  },
                },
                '427bbb3d-3928-4d1f-bcc0-38f7b02b4777' => {
                  'value' => {
                    'id' => '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                    'last_edited_time' => 1_620_017_167_708,
                  },
                },
                '7868b070-cf4d-460e-ae6b-3c407527f7fe' => {
                  'value' => {
                    'id' => '7868b070-cf4d-460e-ae6b-3c407527f7fe',
                    'last_edited_time' => 1_620_017_168_434,
                  },
                },
              },
            },
          },
        )

      notion_space = described_class.new(notion_client)

      expect(notion_space.page_summaries_by_id).to(
        match(
          'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
            an_object_having_attributes(
              id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
            ),
          '427bbb3d-3928-4d1f-bcc0-38f7b02b4777' =>
            an_object_having_attributes(
              id: '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 7.708)),
            ),
          '7868b070-cf4d-460e-ae6b-3c407527f7fe' =>
            an_object_having_attributes(
              id: '7868b070-cf4d-460e-ae6b-3c407527f7fe',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 8.434)),
            ),
        ),
      )
    end
  end
end
