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
          described_class.new.perform('12ba1ded-9372-45a3-adc9-ce985053d7a8')

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
                    '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8.json',
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
                    '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8/d0bc03ce-e9c0-467e-8bba-e9814399c423.json',
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
      context 'and the last_edited_times between the repo and Notion versions of the page are the same' do
        it 'does not create a new commit to update the page in the repo' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8/d0bc03ce-e9c0-467e-8bba-e9814399c423.json' =>
                    JSON.generate(
                      'block' => {
                        'd0bc03ce-e9c0-467e-8bba-e9814399c423' => {
                          'id' => 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                          'value' => {
                            'last_edited_time' => 1_620_968_040_000,
                          },
                        },
                      },
                    ),
                },
              )
            last_commit_time = remote_rugged_repo.last_commit.time

            # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subsubpage"
            described_class.new.perform('d0bc03ce-e9c0-467e-8bba-e9814399c423')

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

      context 'and the last_edited_time on the repo version is earlier than the Notion version' do
        it 'makes a new commit to update the page in the repo' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8/d0bc03ce-e9c0-467e-8bba-e9814399c423.json' =>
                    JSON.generate(
                      'block' => {
                        'd0bc03ce-e9c0-467e-8bba-e9814399c423' => {
                          'id' => 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                          'value' => {
                            'last_edited_time' => 1_620_000_000_000,
                          },
                        },
                      },
                    ),
                },
              )

            # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subsubpage"
            described_class.new.perform('d0bc03ce-e9c0-467e-8bba-e9814399c423')

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              expect(repo.last_commit).to(
                have_attributes(message: 'Automatic sync from notion-capture'),
              )
            end
          end
        end
      end

      context 'and the last_edited_time on the repo version is later than the Notion version' do
        it 'does not create a new commit to update the page in the repo' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8/d0bc03ce-e9c0-467e-8bba-e9814399c423.json' =>
                    JSON.generate(
                      'block' => {
                        'd0bc03ce-e9c0-467e-8bba-e9814399c423' => {
                          'id' => 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                          'value' => {
                            'last_edited_time' => 1_621_000_000_000,
                          },
                        },
                      },
                    ),
                },
              )
            last_commit_time = remote_rugged_repo.last_commit.time

            # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subsubpage"
            described_class.new.perform('d0bc03ce-e9c0-467e-8bba-e9814399c423')

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
