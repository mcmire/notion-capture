RSpec.describe NotionCapture::Notion::Client, vcr: true do
  let(:token_file) do
    Pathname.new('../../cassettes/test-token-file').expand_path(__dir__)
  end

  let(:authenticator) { NotionCapture::Notion::Authenticator.new(token_file) }

  describe '#fetch_spaces!' do
    it 'returns a bunch of data about the spaces, primarily what all of the pages are' do
      notion_client = described_class.new(authenticator)

      json = notion_client.fetch_spaces!

      expect(json).to(
        include(
          'e5b8637d-32a4-4597-8492-652c46372480' =>
            a_hash_including(
              'block' =>
                a_hash_including(
                  '722ba1ef-e17a-4175-90c6-dd123ddf11d4' =>
                    a_hash_including(
                      'value' =>
                        a_hash_including(
                          'id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                          'last_edited_time' => 1_621_817_040_000,
                        ),
                    ),
                  'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1' =>
                    a_hash_including(
                      'value' =>
                        a_hash_including(
                          'id' => 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                          'last_edited_time' => 1_622_006_040_000,
                        ),
                    ),
                ),
            ),
        ),
      )
    end
  end

  describe '#fetch_complete_page!' do
    it 'returns the complete content of the page' do
      notion_client = described_class.new(authenticator)

      json =
        notion_client.fetch_complete_page!(
          '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
        )

      expect(json).to(
        eq(
          {
            'block' => {
              '722ba1ef-e17a-4175-90c6-dd123ddf11d4' => {
                'role' => 'editor',
                'value' => {
                  'id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'version' => 66,
                  'type' => 'page',
                  'properties' => {
                    'title' => [['Test page']],
                  },
                  'content' => %w[
                    483d525b-cba6-4bdb-8186-01c4d6e00bee
                    7ff62e3e-9299-4909-b970-6934358d75f6
                    5b90ba9c-a3a0-40fe-888e-2b959b93ec27
                    77dfebcc-38c4-47dd-854a-e2e97689e267
                    0a3f2184-3980-4439-b60c-f666af3eefed
                    1036c7b3-9df5-4023-8024-813b263d3666
                    2806e26b-a025-4edd-a011-60d80a66124e
                    77eafb0f-5099-4426-abfb-9d793f8fdfbc
                    ab149808-a0ac-47f6-a5f8-721c7337d60d
                    8b69445d-7391-4b1d-ad7c-efa58ec8dce4
                    6e9fff9e-1888-4e1f-a4ba-eda709143bd5
                    af89b008-da3c-4813-bdaf-b45cab2f056e
                    f1e8cb34-b658-49e4-92ba-e6e4423cb500
                    dbdad1f7-e4c9-4c73-8bab-0d9dab41050f
                    6a8e38e5-9f08-4a01-9378-cb2e24137c3d
                    8f237735-7d82-486f-a520-923f617101fe
                    a80b0b66-5200-49b8-abf2-488a0ca0235b
                    a095b789-2b85-4fd5-bec6-cb24cdc7780a
                    14013023-9508-4655-9c87-827a25870fff
                    6e5cb4e5-d110-4026-ba9c-bd334c7227dd
                    0f53c1a3-fd68-4660-ace0-0fc46a6c601b
                    12acc71c-9f64-45b8-bfe2-a5afe4403d75
                    9f69c2de-1c06-4aae-a86a-c1ff1ee59e5a
                    fe11635f-26c1-454f-9827-503ba9c4fab3
                    716320fe-5104-4621-a302-c3dadb749b56
                    01706360-846a-493d-9ee2-932aef1b4afc
                    bce29ca1-6c65-40bb-91fc-b09abe1955ed
                    a4b87d39-ad13-4167-801c-609dff8c05a1
                    bf826320-91de-4371-a485-49ecae52a1a4
                    565533fc-fa28-4a9e-856c-fe9fe26f4473
                    beaf63c8-e288-4d24-a516-b96088589a71
                    d9a36e8a-d45b-4449-852b-7a94ddada603
                    9998b039-5612-4121-8101-7ea124b9507e
                    94bd37b0-4bdc-4bc5-a18a-66881e687d13
                    c025724a-f9e9-4721-84b4-ab6a863bd3a3
                    977b83a9-1b1e-4739-8234-2f6006e54e53
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                  ],
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_621_817_040_000,
                  'parent_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                  'parent_table' => 'space',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '483d525b-cba6-4bdb-8186-01c4d6e00bee' => {
                'role' => 'editor',
                'value' => {
                  'id' => '483d525b-cba6-4bdb-8186-01c4d6e00bee',
                  'version' => 147,
                  'type' => 'text',
                  'properties' => {
                    'title' => [
                      [
                        'This page has more than 30 blocks in it, so that the endpoint is forced to paginate.',
                      ],
                    ],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_621_817_040_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '7ff62e3e-9299-4909-b970-6934358d75f6' => {
                'role' => 'editor',
                'value' => {
                  'id' => '7ff62e3e-9299-4909-b970-6934358d75f6',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['B']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '5b90ba9c-a3a0-40fe-888e-2b959b93ec27' => {
                'role' => 'editor',
                'value' => {
                  'id' => '5b90ba9c-a3a0-40fe-888e-2b959b93ec27',
                  'version' => 12,
                  'type' => 'sub_sub_header',
                  'properties' => {
                    'title' => [['C']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_960_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '77dfebcc-38c4-47dd-854a-e2e97689e267' => {
                'role' => 'editor',
                'value' => {
                  'id' => '77dfebcc-38c4-47dd-854a-e2e97689e267',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['D']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '0a3f2184-3980-4439-b60c-f666af3eefed' => {
                'role' => 'editor',
                'value' => {
                  'id' => '0a3f2184-3980-4439-b60c-f666af3eefed',
                  'version' => 16,
                  'type' => 'bulleted_list',
                  'properties' => {
                    'title' => [['E']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '1036c7b3-9df5-4023-8024-813b263d3666' => {
                'role' => 'editor',
                'value' => {
                  'id' => '1036c7b3-9df5-4023-8024-813b263d3666',
                  'version' => 15,
                  'type' => 'bulleted_list',
                  'properties' => {
                    'title' => [['F']],
                  },
                  'content' => ['2f844e23-f3b5-4bc5-adc3-8dd5dde502ee'],
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '2f844e23-f3b5-4bc5-adc3-8dd5dde502ee' => {
                'role' => 'editor',
                'value' => {
                  'id' => '2f844e23-f3b5-4bc5-adc3-8dd5dde502ee',
                  'version' => 13,
                  'type' => 'bulleted_list',
                  'properties' => {
                    'title' => [['G']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '1036c7b3-9df5-4023-8024-813b263d3666',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '2806e26b-a025-4edd-a011-60d80a66124e' => {
                'role' => 'editor',
                'value' => {
                  'id' => '2806e26b-a025-4edd-a011-60d80a66124e',
                  'version' => 15,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['H']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '77eafb0f-5099-4426-abfb-9d793f8fdfbc' => {
                'role' => 'editor',
                'value' => {
                  'id' => '77eafb0f-5099-4426-abfb-9d793f8fdfbc',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['I']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'ab149808-a0ac-47f6-a5f8-721c7337d60d' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'ab149808-a0ac-47f6-a5f8-721c7337d60d',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['J']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '8b69445d-7391-4b1d-ad7c-efa58ec8dce4' => {
                'role' => 'editor',
                'value' => {
                  'id' => '8b69445d-7391-4b1d-ad7c-efa58ec8dce4',
                  'version' => 12,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['K']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '6e9fff9e-1888-4e1f-a4ba-eda709143bd5' => {
                'role' => 'editor',
                'value' => {
                  'id' => '6e9fff9e-1888-4e1f-a4ba-eda709143bd5',
                  'version' => 14,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['L']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'af89b008-da3c-4813-bdaf-b45cab2f056e' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'af89b008-da3c-4813-bdaf-b45cab2f056e',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['M']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'f1e8cb34-b658-49e4-92ba-e6e4423cb500' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'f1e8cb34-b658-49e4-92ba-e6e4423cb500',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['N']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'dbdad1f7-e4c9-4c73-8bab-0d9dab41050f' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'dbdad1f7-e4c9-4c73-8bab-0d9dab41050f',
                  'version' => 12,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['O', [%w[a http://google.com]]]],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_960_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '6a8e38e5-9f08-4a01-9378-cb2e24137c3d' => {
                'role' => 'editor',
                'value' => {
                  'id' => '6a8e38e5-9f08-4a01-9378-cb2e24137c3d',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['P']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '8f237735-7d82-486f-a520-923f617101fe' => {
                'role' => 'editor',
                'value' => {
                  'id' => '8f237735-7d82-486f-a520-923f617101fe',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['Q']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'a80b0b66-5200-49b8-abf2-488a0ca0235b' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'a80b0b66-5200-49b8-abf2-488a0ca0235b',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['R']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'a095b789-2b85-4fd5-bec6-cb24cdc7780a' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'a095b789-2b85-4fd5-bec6-cb24cdc7780a',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['S']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '14013023-9508-4655-9c87-827a25870fff' => {
                'role' => 'editor',
                'value' => {
                  'id' => '14013023-9508-4655-9c87-827a25870fff',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['T']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '6e5cb4e5-d110-4026-ba9c-bd334c7227dd' => {
                'role' => 'editor',
                'value' => {
                  'id' => '6e5cb4e5-d110-4026-ba9c-bd334c7227dd',
                  'version' => 14,
                  'type' => 'header',
                  'properties' => {
                    'title' => [['U']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_960_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '0f53c1a3-fd68-4660-ace0-0fc46a6c601b' => {
                'role' => 'editor',
                'value' => {
                  'id' => '0f53c1a3-fd68-4660-ace0-0fc46a6c601b',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['V']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '12acc71c-9f64-45b8-bfe2-a5afe4403d75' => {
                'role' => 'editor',
                'value' => {
                  'id' => '12acc71c-9f64-45b8-bfe2-a5afe4403d75',
                  'version' => 12,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['W']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '9f69c2de-1c06-4aae-a86a-c1ff1ee59e5a' => {
                'role' => 'editor',
                'value' => {
                  'id' => '9f69c2de-1c06-4aae-a86a-c1ff1ee59e5a',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['X']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'fe11635f-26c1-454f-9827-503ba9c4fab3' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'fe11635f-26c1-454f-9827-503ba9c4fab3',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['Y']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '716320fe-5104-4621-a302-c3dadb749b56' => {
                'role' => 'editor',
                'value' => {
                  'id' => '716320fe-5104-4621-a302-c3dadb749b56',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['Z']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '01706360-846a-493d-9ee2-932aef1b4afc' => {
                'role' => 'editor',
                'value' => {
                  'id' => '01706360-846a-493d-9ee2-932aef1b4afc',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['1']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'bce29ca1-6c65-40bb-91fc-b09abe1955ed' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'bce29ca1-6c65-40bb-91fc-b09abe1955ed',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['2']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'a4b87d39-ad13-4167-801c-609dff8c05a1' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'a4b87d39-ad13-4167-801c-609dff8c05a1',
                  'version' => 12,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['3']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'bf826320-91de-4371-a485-49ecae52a1a4' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'bf826320-91de-4371-a485-49ecae52a1a4',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['4']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '565533fc-fa28-4a9e-856c-fe9fe26f4473' => {
                'role' => 'editor',
                'value' => {
                  'id' => '565533fc-fa28-4a9e-856c-fe9fe26f4473',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['5']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'beaf63c8-e288-4d24-a516-b96088589a71' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'beaf63c8-e288-4d24-a516-b96088589a71',
                  'version' => 12,
                  'type' => 'sub_header',
                  'properties' => {
                    'title' => [['6']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_960_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'd9a36e8a-d45b-4449-852b-7a94ddada603' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'd9a36e8a-d45b-4449-852b-7a94ddada603',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['6']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '9998b039-5612-4121-8101-7ea124b9507e' => {
                'role' => 'editor',
                'value' => {
                  'id' => '9998b039-5612-4121-8101-7ea124b9507e',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['7']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '94bd37b0-4bdc-4bc5-a18a-66881e687d13' => {
                'role' => 'editor',
                'value' => {
                  'id' => '94bd37b0-4bdc-4bc5-a18a-66881e687d13',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['8']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              'c025724a-f9e9-4721-84b4-ab6a863bd3a3' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'c025724a-f9e9-4721-84b4-ab6a863bd3a3',
                  'version' => 10,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['9']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '977b83a9-1b1e-4739-8234-2f6006e54e53' => {
                'role' => 'editor',
                'value' => {
                  'id' => '977b83a9-1b1e-4739-8234-2f6006e54e53',
                  'version' => 11,
                  'type' => 'text',
                  'properties' => {
                    'title' => [['10']],
                  },
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_620_105_900_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '0ecc4427-3c80-4b97-9e70-9f35ac4c5405' => {
                'role' => 'editor',
                'value' => {
                  'id' => '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                  'version' => 53,
                  'type' => 'page',
                  'properties' => {
                    'title' => [['Test subpage']],
                  },
                  'content' => %w[
                    2644cda5-4619-4aed-9959-da51754a758b
                    227fd83a-546c-48f2-abde-14a08c43faae
                    d0bc03ce-e9c0-467e-8bba-e9814399c423
                  ],
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'created_time' => 1_621_809_900_000,
                  'last_edited_time' => 1_621_816_980_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
            },
            'space' => {
              '9292b46f-54ab-41db-b39d-17436d8f8f14' => {
                'role' => 'editor',
                'value' => {
                  'id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                  'version' => 41,
                  'name' => "Elliot's Notion",
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'beta_enabled' => false,
                  'pages' => %w[
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                  ],
                  'created_time' => 1_620_017_165_450,
                  'last_edited_time' => 1_621_817_040_000,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'plan_type' => 'personal',
                  'invite_link_enabled' => true,
                },
              },
            },
          },
        ),
      )
    end
  end

  describe '#fetch_page_lineage!' do
    it 'returns the lineage of the given page based on its backlinks' do
      notion_client = described_class.new(authenticator)

      lineage =
        notion_client.fetch_page_lineage!(
          'd0bc03ce-e9c0-467e-8bba-e9814399c423',
        )

      expect(lineage).to(
        eq(
          %w[
            d0bc03ce-e9c0-467e-8bba-e9814399c423
            0ecc4427-3c80-4b97-9e70-9f35ac4c5405
            722ba1ef-e17a-4175-90c6-dd123ddf11d4
          ],
        ),
      )
    end
  end

  describe '#fetch_collection_view!' do
    it 'returns data about the given collection view id and its collection id' do
      notion_client = described_class.new(authenticator)

      data =
        notion_client.fetch_collection_view!(
          id: '80482a7b-195b-4665-82f1-0a7825e77476',
          collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
        )

      expect(data).to eq(
        {
          'result' => {
            'type' => 'reducer',
            'reducerResults' => {
              'collection_group_results' => {
                'type' => 'results',
                'blockIds' => %w[
                  42c4bd06-12ee-4808-9624-1e7e9e7f3a5f
                  9211601a-9016-484a-8313-f54a459a5a2a
                  2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a
                ],
                'total' => 3,
              },
            },
          },
          'recordMap' => {
            'collection' => {
              'b12633f5-5288-4fd6-b7c9-e726780fa287' => {
                'role' => 'editor',
                'value' => {
                  'id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                  'version' => 25,
                  'name' => [['Test subtable']],
                  'schema' => {
                    'JcMG' => {
                      'name' => 'Website',
                      'type' => 'url',
                    },
                    '_WKf' => {
                      'name' => 'Age',
                      'type' => 'number',
                    },
                    'title' => {
                      'name' => 'Name',
                      'type' => 'title',
                    },
                  },
                  'format' => {
                    'collection_page_properties' => [
                      { 'visible' => true, 'property' => '_WKf' },
                    ],
                  },
                  'parent_id' => '227fd83a-546c-48f2-abde-14a08c43faae',
                  'parent_table' => 'block',
                  'alive' => true,
                  'migrated' => true,
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
            },
            'collection_view' => {
              '80482a7b-195b-4665-82f1-0a7825e77476' => {
                'role' => 'editor',
                'value' => {
                  'id' => '80482a7b-195b-4665-82f1-0a7825e77476',
                  'version' => 1,
                  'type' => 'list',
                  'name' => 'List view',
                  'parent_id' => '227fd83a-546c-48f2-abde-14a08c43faae',
                  'parent_table' => 'block',
                  'alive' => true,
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
            },
            'block' => {
              '227fd83a-546c-48f2-abde-14a08c43faae' => {
                'role' => 'editor',
                'value' => {
                  'id' => '227fd83a-546c-48f2-abde-14a08c43faae',
                  'version' => 16,
                  'type' => 'collection_view',
                  'view_ids' => %w[
                    ce55eba9-ab50-4f33-ac0d-df6ba7132973
                    80482a7b-195b-4665-82f1-0a7825e77476
                  ],
                  'collection_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                  'created_time' => 1_621_809_983_877,
                  'last_edited_time' => 1_621_831_680_000,
                  'parent_id' => '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '0ecc4427-3c80-4b97-9e70-9f35ac4c5405' => {
                'role' => 'editor',
                'value' => {
                  'id' => '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                  'version' => 53,
                  'type' => 'page',
                  'properties' => {
                    'title' => [['Test subpage']],
                  },
                  'content' => %w[
                    2644cda5-4619-4aed-9959-da51754a758b
                    227fd83a-546c-48f2-abde-14a08c43faae
                    d0bc03ce-e9c0-467e-8bba-e9814399c423
                  ],
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'created_time' => 1_621_809_900_000,
                  'last_edited_time' => 1_621_816_980_000,
                  'parent_id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'parent_table' => 'block',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '722ba1ef-e17a-4175-90c6-dd123ddf11d4' => {
                'role' => 'editor',
                'value' => {
                  'id' => '722ba1ef-e17a-4175-90c6-dd123ddf11d4',
                  'version' => 66,
                  'type' => 'page',
                  'properties' => {
                    'title' => [['Test page']],
                  },
                  'content' => %w[
                    483d525b-cba6-4bdb-8186-01c4d6e00bee
                    7ff62e3e-9299-4909-b970-6934358d75f6
                    5b90ba9c-a3a0-40fe-888e-2b959b93ec27
                    77dfebcc-38c4-47dd-854a-e2e97689e267
                    0a3f2184-3980-4439-b60c-f666af3eefed
                    1036c7b3-9df5-4023-8024-813b263d3666
                    2806e26b-a025-4edd-a011-60d80a66124e
                    77eafb0f-5099-4426-abfb-9d793f8fdfbc
                    ab149808-a0ac-47f6-a5f8-721c7337d60d
                    8b69445d-7391-4b1d-ad7c-efa58ec8dce4
                    6e9fff9e-1888-4e1f-a4ba-eda709143bd5
                    af89b008-da3c-4813-bdaf-b45cab2f056e
                    f1e8cb34-b658-49e4-92ba-e6e4423cb500
                    dbdad1f7-e4c9-4c73-8bab-0d9dab41050f
                    6a8e38e5-9f08-4a01-9378-cb2e24137c3d
                    8f237735-7d82-486f-a520-923f617101fe
                    a80b0b66-5200-49b8-abf2-488a0ca0235b
                    a095b789-2b85-4fd5-bec6-cb24cdc7780a
                    14013023-9508-4655-9c87-827a25870fff
                    6e5cb4e5-d110-4026-ba9c-bd334c7227dd
                    0f53c1a3-fd68-4660-ace0-0fc46a6c601b
                    12acc71c-9f64-45b8-bfe2-a5afe4403d75
                    9f69c2de-1c06-4aae-a86a-c1ff1ee59e5a
                    fe11635f-26c1-454f-9827-503ba9c4fab3
                    716320fe-5104-4621-a302-c3dadb749b56
                    01706360-846a-493d-9ee2-932aef1b4afc
                    bce29ca1-6c65-40bb-91fc-b09abe1955ed
                    a4b87d39-ad13-4167-801c-609dff8c05a1
                    bf826320-91de-4371-a485-49ecae52a1a4
                    565533fc-fa28-4a9e-856c-fe9fe26f4473
                    beaf63c8-e288-4d24-a516-b96088589a71
                    d9a36e8a-d45b-4449-852b-7a94ddada603
                    9998b039-5612-4121-8101-7ea124b9507e
                    94bd37b0-4bdc-4bc5-a18a-66881e687d13
                    c025724a-f9e9-4721-84b4-ab6a863bd3a3
                    977b83a9-1b1e-4739-8234-2f6006e54e53
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                  ],
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'created_time' => 1_620_105_900_000,
                  'last_edited_time' => 1_621_817_040_000,
                  'parent_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                  'parent_table' => 'space',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f' => {
                'role' => 'editor',
                'value' => {
                  'id' => '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                  'version' => 49,
                  'type' => 'page',
                  'properties' => {
                    'JcMG' => [['http://sally.com', [%w[a http://sally.com]]]],
                    '_WKf' => [['57']],
                    'title' => [['Sally']],
                  },
                  'created_time' => 1_621_809_983_877,
                  'last_edited_time' => 1_621_810_020_000,
                  'parent_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                  'parent_table' => 'collection',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '9211601a-9016-484a-8313-f54a459a5a2a' => {
                'role' => 'editor',
                'value' => {
                  'id' => '9211601a-9016-484a-8313-f54a459a5a2a',
                  'version' => 34,
                  'type' => 'page',
                  'properties' => {
                    'JcMG' => [['http://steve.com', [%w[a http://steve.com]]]],
                    '_WKf' => [['23']],
                    'title' => [['Steve']],
                  },
                  'created_time' => 1_621_809_983_877,
                  'last_edited_time' => 1_621_810_020_000,
                  'parent_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                  'parent_table' => 'collection',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
              '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a' => {
                'role' => 'editor',
                'value' => {
                  'id' => '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
                  'version' => 30,
                  'type' => 'page',
                  'properties' => {
                    'JcMG' => [['http://joe.com', [%w[a http://joe.com]]]],
                    '_WKf' => [['12']],
                    'title' => [['Joe']],
                  },
                  'created_time' => 1_621_809_983_877,
                  'last_edited_time' => 1_621_810_020_000,
                  'parent_id' => 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                  'parent_table' => 'collection',
                  'alive' => true,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'space_id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                },
              },
            },
            'space' => {
              '9292b46f-54ab-41db-b39d-17436d8f8f14' => {
                'role' => 'editor',
                'value' => {
                  'id' => '9292b46f-54ab-41db-b39d-17436d8f8f14',
                  'version' => 41,
                  'name' => "Elliot's Notion",
                  'permissions' => [
                    {
                      'role' => 'editor',
                      'type' => 'user_permission',
                      'user_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                    },
                  ],
                  'beta_enabled' => false,
                  'pages' => %w[
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                  ],
                  'created_time' => 1_620_017_165_450,
                  'last_edited_time' => 1_621_817_040_000,
                  'created_by_table' => 'notion_user',
                  'created_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'last_edited_by_table' => 'notion_user',
                  'last_edited_by_id' => 'e5b8637d-32a4-4597-8492-652c46372480',
                  'plan_type' => 'personal',
                  'invite_link_enabled' => true,
                },
              },
            },
          },
        },
      )
    end
  end
end
