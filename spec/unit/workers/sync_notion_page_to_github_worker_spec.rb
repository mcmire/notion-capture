RSpec.describe(
  NotionCapture::Workers::SyncNotionPageToGithubWorker,
  vcr: true,
) do
  describe '#perform' do
    context 'if the Git repo does not have the given Notion page yet' do
      it 'pushes a new commit to this repo with the page, and all of its subpages, inside' do
        with_configuration do
          remote_rugged_repo =
            set_up_remote_repo(files: { 'foo.txt' => 'this is a foo' })

          # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subpage"
          described_class.new.perform(
            '12ba1ded-9372-45a3-adc9-ce985053d7a8',
            '9292b46f-54ab-41db-b39d-17436d8f8f14',
          )

          local_rugged_repo = Rugged::Repository.new(local_repo_dir)
          [local_rugged_repo, remote_rugged_repo].each do |repo|
            expect(repo.last_commit).to(
              have_attributes(message: 'Automatic sync from notion-capture'),
            )
            expect(repo.last_commit.tree).to be_a_git_tree(
              [
                { path: 'foo.txt', content: 'this is a foo' },
                {
                  path:
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      12ba1ded-9372-45a3-adc9-ce985053d7a8.json
                    ].join('/'),
                  content:
                    a_json_blob_including(
                      'block' =>
                        a_hash_including(
                          '12ba1ded-9372-45a3-adc9-ce985053d7a8' =>
                            a_hash_including(
                              'value' =>
                                a_hash_including(
                                  'id' =>
                                    '12ba1ded-9372-45a3-adc9-ce985053d7a8',
                                  'properties' => {
                                    'title' => [['Test subpage']],
                                  },
                                ),
                            ),
                        ),
                    ),
                },
                {
                  path:
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      12ba1ded-9372-45a3-adc9-ce985053d7a8
                      d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                    ].join('/'),
                  content:
                    a_json_blob_including(
                      'block' =>
                        a_hash_including(
                          'd0bc03ce-e9c0-467e-8bba-e9814399c423' =>
                            a_hash_including(
                              'value' =>
                                a_hash_including(
                                  'id' =>
                                    'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                                  'properties' => {
                                    'title' => [['Test subsubpage']],
                                  },
                                ),
                            ),
                        ),
                    ),
                },
              ],
            )
          end
        end
      end
    end

    context 'if the Git repo already has the given Notion page' do
      context 'and the content between the repo and Notion versions of the page is the same' do
        it 'does not create a new commit to update the page in the repo' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  %w[
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    12ba1ded-9372-45a3-adc9-ce985053d7a8
                    d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                  ].join('/') =>
                    "{\"block\":{\"d0bc03ce-e9c0-467e-8bba-e9814399c423\":{\"role\":\"editor\",\"value\":{\"id\":\"d0bc03ce-e9c0-467e-8bba-e9814399c423\",\"version\":38,\"type\":\"page\",\"properties\":{\"title\":[[\"Test subsubpage\"]]},\"content\":[\"b6b55522-7c8f-4570-9bd6-d4d467cc269d\"],\"created_time\":1620968040000,\"last_edited_time\":1620968040000,\"parent_id\":\"12ba1ded-9372-45a3-adc9-ce985053d7a8\",\"parent_table\":\"block\",\"alive\":true,\"created_by_table\":\"notion_user\",\"created_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"last_edited_by_table\":\"notion_user\",\"last_edited_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"space_id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\"}},\"12ba1ded-9372-45a3-adc9-ce985053d7a8\":{\"role\":\"editor\",\"value\":{\"id\":\"12ba1ded-9372-45a3-adc9-ce985053d7a8\",\"version\":33,\"type\":\"page\",\"properties\":{\"title\":[[\"Test subpage\"]]},\"content\":[\"9cee1f86-c21c-49df-ab05-af524d084b1a\",\"d0bc03ce-e9c0-467e-8bba-e9814399c423\"],\"created_time\":1620964620000,\"last_edited_time\":1620968040000,\"parent_id\":\"722ba1ef-e17a-4175-90c6-dd123ddf11d4\",\"parent_table\":\"block\",\"alive\":true,\"created_by_table\":\"notion_user\",\"created_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"last_edited_by_table\":\"notion_user\",\"last_edited_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"space_id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\"}},\"722ba1ef-e17a-4175-90c6-dd123ddf11d4\":{\"role\":\"editor\",\"value\":{\"id\":\"722ba1ef-e17a-4175-90c6-dd123ddf11d4\",\"version\":61,\"type\":\"page\",\"properties\":{\"title\":[[\"Test page\"]]},\"content\":[\"483d525b-cba6-4bdb-8186-01c4d6e00bee\",\"7ff62e3e-9299-4909-b970-6934358d75f6\",\"5b90ba9c-a3a0-40fe-888e-2b959b93ec27\",\"77dfebcc-38c4-47dd-854a-e2e97689e267\",\"0a3f2184-3980-4439-b60c-f666af3eefed\",\"1036c7b3-9df5-4023-8024-813b263d3666\",\"2806e26b-a025-4edd-a011-60d80a66124e\",\"77eafb0f-5099-4426-abfb-9d793f8fdfbc\",\"ab149808-a0ac-47f6-a5f8-721c7337d60d\",\"8b69445d-7391-4b1d-ad7c-efa58ec8dce4\",\"6e9fff9e-1888-4e1f-a4ba-eda709143bd5\",\"af89b008-da3c-4813-bdaf-b45cab2f056e\",\"f1e8cb34-b658-49e4-92ba-e6e4423cb500\",\"dbdad1f7-e4c9-4c73-8bab-0d9dab41050f\",\"6a8e38e5-9f08-4a01-9378-cb2e24137c3d\",\"8f237735-7d82-486f-a520-923f617101fe\",\"a80b0b66-5200-49b8-abf2-488a0ca0235b\",\"a095b789-2b85-4fd5-bec6-cb24cdc7780a\",\"14013023-9508-4655-9c87-827a25870fff\",\"6e5cb4e5-d110-4026-ba9c-bd334c7227dd\",\"0f53c1a3-fd68-4660-ace0-0fc46a6c601b\",\"12acc71c-9f64-45b8-bfe2-a5afe4403d75\",\"9f69c2de-1c06-4aae-a86a-c1ff1ee59e5a\",\"fe11635f-26c1-454f-9827-503ba9c4fab3\",\"716320fe-5104-4621-a302-c3dadb749b56\",\"01706360-846a-493d-9ee2-932aef1b4afc\",\"bce29ca1-6c65-40bb-91fc-b09abe1955ed\",\"a4b87d39-ad13-4167-801c-609dff8c05a1\",\"bf826320-91de-4371-a485-49ecae52a1a4\",\"565533fc-fa28-4a9e-856c-fe9fe26f4473\",\"beaf63c8-e288-4d24-a516-b96088589a71\",\"d9a36e8a-d45b-4449-852b-7a94ddada603\",\"9998b039-5612-4121-8101-7ea124b9507e\",\"94bd37b0-4bdc-4bc5-a18a-66881e687d13\",\"c025724a-f9e9-4721-84b4-ab6a863bd3a3\",\"977b83a9-1b1e-4739-8234-2f6006e54e53\",\"12ba1ded-9372-45a3-adc9-ce985053d7a8\"],\"permissions\":[{\"role\":\"editor\",\"type\":\"user_permission\",\"user_id\":\"e5b8637d-32a4-4597-8492-652c46372480\"}],\"created_time\":1620105900000,\"last_edited_time\":1620964620000,\"parent_id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\",\"parent_table\":\"space\",\"alive\":true,\"created_by_table\":\"notion_user\",\"created_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"last_edited_by_table\":\"notion_user\",\"last_edited_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"space_id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\"}},\"b6b55522-7c8f-4570-9bd6-d4d467cc269d\":{\"role\":\"editor\",\"value\":{\"id\":\"b6b55522-7c8f-4570-9bd6-d4d467cc269d\",\"version\":17,\"type\":\"text\",\"properties\":{\"title\":[[\"Yeah man\"]]},\"created_time\":1620968040000,\"last_edited_time\":1620968040000,\"parent_id\":\"d0bc03ce-e9c0-467e-8bba-e9814399c423\",\"parent_table\":\"block\",\"alive\":true,\"created_by_table\":\"notion_user\",\"created_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"last_edited_by_table\":\"notion_user\",\"last_edited_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"space_id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\"}}},\"space\":{\"9292b46f-54ab-41db-b39d-17436d8f8f14\":{\"role\":\"editor\",\"value\":{\"id\":\"9292b46f-54ab-41db-b39d-17436d8f8f14\",\"version\":12,\"name\":\"Elliot's Notion\",\"permissions\":[{\"role\":\"editor\",\"type\":\"user_permission\",\"user_id\":\"e5b8637d-32a4-4597-8492-652c46372480\"}],\"beta_enabled\":false,\"pages\":[\"8d367ce1-db33-4367-8088-243c877c2954\",\"96906133-ad6c-4883-b1b3-f308ab59c3a8\",\"5a6eabf3-2a2d-439d-968b-8435c91a754a\",\"03be1b94-12ac-4bc3-be3d-ea2e30d02197\",\"265cf337-46a0-4300-a89a-2b10889efbca\",\"9af6fc30-4316-4c2b-9958-632c857a20d7\",\"722ba1ef-e17a-4175-90c6-dd123ddf11d4\",\"199f9859-47a1-4136-884e-9f39dc1577e1\"],\"created_time\":1620017165450,\"last_edited_time\":1621742820000,\"created_by_table\":\"notion_user\",\"created_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"last_edited_by_table\":\"notion_user\",\"last_edited_by_id\":\"e5b8637d-32a4-4597-8492-652c46372480\",\"plan_type\":\"personal\",\"invite_link_enabled\":true}}}}",
                },
              )
            last_commit_time = remote_rugged_repo.last_commit.time

            # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subsubpage"
            described_class.new.perform(
              'd0bc03ce-e9c0-467e-8bba-e9814399c423',
              '9292b46f-54ab-41db-b39d-17436d8f8f14',
            )

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              expect(repo.last_commit).to(
                have_attributes(
                  message: 'Initial commit',
                  time: last_commit_time,
                ),
              )
            end
          end
        end
      end

      context 'and the content between the repo and Notion versions of the page is different' do
        it 'makes a new commit to update the page in the repo' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  %w[
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    12ba1ded-9372-45a3-adc9-ce985053d7a8
                    d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                  ].join('/') =>
                    JSON.generate(
                      'block' => {
                        'd0bc03ce-e9c0-467e-8bba-e9814399c423' => {
                          'id' => 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                          'value' => {
                            'something' => 'totally different',
                          },
                        },
                      },
                    ),
                },
              )

            # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subsubpage"
            described_class.new.perform(
              'd0bc03ce-e9c0-467e-8bba-e9814399c423',
              '9292b46f-54ab-41db-b39d-17436d8f8f14',
            )

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              expect(repo.last_commit).to(
                have_attributes(message: 'Automatic sync from notion-capture'),
              )
            end
          end
        end
      end
    end
  end

  def with_configuration(&block)
    NotionCapture.with_configuration(
      remote_repo_url: "file://#{remote_repo_dir}",
      local_repo_dir: local_repo_dir,
      lockfile_path: lockfile_path,
      &block
    )
  end

  def set_up_remote_repo(files:)
    create_rugged_repo(directory: remote_repo_dir, bare: true)
      .tap do |remote_rugged_repo|
      create_rugged_repo(
        directory: remote_stage_repo_dir,
        remotes: {
          'upstream' => "file://#{remote_repo_dir}",
        },
        index: files,
        commit: true,
        push_to: 'upstream',
      )
      remote_rugged_repo.head = 'refs/heads/main'
    end
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local')
  end

  def remote_stage_repo_dir
    @remote_stage_repo_dir ||= tmp_dir.join('repo-remote-stage')
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote')
  end

  def lockfile_path
    @lockfile_path ||= tmp_dir.join('repo-local.lock')
  end
end
