RSpec.describe NotionCapture::NotionClient, vcr: true do
  let(:notion_client) { described_class.new }

  describe "#fetch_spaces!" do
    it "returns a bunch of data about the spaces, primarily what all of the pages are" do
      response = notion_client.fetch_spaces!

      expect(response.parse).to include(
        "e5b8637d-32a4-4597-8492-652c46372480" => a_hash_including(
          "block" => a_hash_including(
            "8d367ce1-db33-4367-8088-243c877c2954" => a_hash_including(
              "value" => a_hash_including(
                "id" => "8d367ce1-db33-4367-8088-243c877c2954",
                "last_edited_time" => 1620017160000,
              )
            ),
            "96906133-ad6c-4883-b1b3-f308ab59c3a8" => a_hash_including(
              "value" => a_hash_including(
                "id" => "96906133-ad6c-4883-b1b3-f308ab59c3a8",
                "last_edited_time" => 1620017167709
              )
            ),
            "5a6eabf3-2a2d-439d-968b-8435c91a754a" => a_hash_including(
              "value" => a_hash_including(
                "id" => "5a6eabf3-2a2d-439d-968b-8435c91a754a",
                "last_edited_time" => 1620017167708,
              )
            ),
            "03be1b94-12ac-4bc3-be3d-ea2e30d02197" => a_hash_including(
              "value" => a_hash_including(
                "id" => "03be1b94-12ac-4bc3-be3d-ea2e30d02197",
                "last_edited_time" => 1620017167711,
              )
            ),
            "265cf337-46a0-4300-a89a-2b10889efbca" => a_hash_including(
              "value" => a_hash_including(
                "id" => "265cf337-46a0-4300-a89a-2b10889efbca",
                "last_edited_time" => 1620017167712,
              )
            ),
            "9af6fc30-4316-4c2b-9958-632c857a20d7" => a_hash_including(
              "value" => a_hash_including(
                "id" => "9af6fc30-4316-4c2b-9958-632c857a20d7",
                "last_edited_time" => 1620017167730,
              )
            )
          )
        )
      )
    end
  end
end
