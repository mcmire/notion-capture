RSpec.describe NotionCapture::NotionSpace do
  let(:notion_space) { described_class.new(notion_client) }

  describe "#page_summaries_by_id" do
    let(:notion_client) do
      double(
        :notion_client,
        user_id: "some-user-id",
        fetch_spaces!: {
          "some-user-id" => {
            "block" => {
              "a" => {
                "value" => {
                  "id" => "1",
                  "last_edited_time" => 1620017167711
                }
              },

              "b" => {
                "value" => {
                  "id" => "2",
                  "last_edited_time" => 1620017167708
                }
              },

              "c" => {
                "value" => {
                  "id" => "3",
                  "last_edited_time" => 1620017168434
                }
              }
            }
          }
        }
      )
    end

    it "returns all pages under the space as a hash of Notion page id => PageSummary" do
      expect(notion_space.page_summaries_by_id).to(
        match(
          {
            "1" => an_object_having_attributes(
              id: "1",
              last_edited_time: a_time_around(
                Time.local(2021, 5, 2, 22, 46, 7.711)
              )
            ),

            "2" => an_object_having_attributes(
              id: "2",
              last_edited_time: a_time_around(
                Time.local(2021, 5, 2, 22, 46, 7.708)
              )
            ),

            "3" => an_object_having_attributes(
              id: "3",
              last_edited_time: a_time_around(
                Time.local(2021, 5, 2, 22, 46, 8.434)
              )
            )
          }
        )
      )
    end
  end
end
