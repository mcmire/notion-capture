RSpec.describe NotionCapture::Workers::SyncNotionCollectionViewToGithubWorker do
  describe '#perform' do
    context 'if the Git repo does not have the given Notion collection view yet' do
      it(
        'pushes a new commit to this repo with the page, and all of its subpages, inside',
        vcr: {
          cassette_name:
            'NotionCapture::Workers::SyncNotionCollectionViewToGithubWorker/Test subtable',
        },
      ) do
        with_configuration do
          remote_rugged_repo =
            set_up_remote_repo(files: { 'foo.txt' => 'this is a foo' })

          # ce55eba9-ab50-4f33-ac0d-df6ba7132973 is "Test subtable"
          described_class.new.perform(
            'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
            'b12633f5-5288-4fd6-b7c9-e726780fa287',
            %w[
              722ba1ef-e17a-4175-90c6-dd123ddf11d4
              0ecc4427-3c80-4b97-9e70-9f35ac4c5405
            ],
            '9292b46f-54ab-41db-b39d-17436d8f8f14',
          )

          local_rugged_repo = Rugged::Repository.new(local_repo_dir)
          [local_rugged_repo, remote_rugged_repo].each do |repo|
            expect(repo.last_commit).to(
              have_attributes(
                message:
                  'Sync collection view ce55eba9-ab50-4f33-ac0d-df6ba7132973',
              ),
            )
            expect(repo.last_commit.tree).to be_a_git_tree(
              [
                { name: 'foo.txt', path: 'foo.txt', content: 'this is a foo' },
                {
                  name: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973.json',
                  path:
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      collection_views
                      ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                    ].join('/'),
                  content:
                    a_hash_including(
                      'result' =>
                        a_hash_including(
                          'reducerResults' => {
                            'collection_group_results' =>
                              a_hash_including(
                                'blockIds' => %w[
                                  9211601a-9016-484a-8313-f54a459a5a2a
                                  42c4bd06-12ee-4808-9624-1e7e9e7f3a5f
                                  2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a
                                ],
                              ),
                          },
                        ),
                      'recordMap' =>
                        a_hash_including(
                          'block' =>
                            a_hash_including(
                              '9211601a-9016-484a-8313-f54a459a5a2a',
                              '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                              '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
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
        it(
          'does not create a new commit to update the page in the repo',
          vcr: {
            cassette_name:
              'NotionCapture::Workers::SyncNotionCollectionViewToGithubWorker/Test subtable',
          },
        ) do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  %w[
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    collection_views
                    ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                  ].join('/') =>
                    collection_view_file_data_in(VCR.current_cassette.file),
                },
              )
            last_commit_time = remote_rugged_repo.last_commit.time

            # ce55eba9-ab50-4f33-ac0d-df6ba7132973 is "Test subtable"
            described_class.new.perform(
              'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
              'b12633f5-5288-4fd6-b7c9-e726780fa287',
              %w[
                722ba1ef-e17a-4175-90c6-dd123ddf11d4
                0ecc4427-3c80-4b97-9e70-9f35ac4c5405
              ],
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
        it(
          'makes a new commit to update the page in the repo',
          vcr: {
            cassette_name:
              'NotionCapture::Workers::SyncNotionCollectionViewToGithubWorker/Test subtable',
          },
        ) do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(
                files: {
                  %w[
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    collection_views
                    ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                  ].join('/') =>
                    JSON.generate({}),
                },
              )

            # ce55eba9-ab50-4f33-ac0d-df6ba7132973 is "Test subtable"
            described_class.new.perform(
              'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
              'b12633f5-5288-4fd6-b7c9-e726780fa287',
              %w[
                722ba1ef-e17a-4175-90c6-dd123ddf11d4
                0ecc4427-3c80-4b97-9e70-9f35ac4c5405
              ],
              '9292b46f-54ab-41db-b39d-17436d8f8f14',
            )

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              expect(repo.last_commit).to(
                have_attributes(
                  message:
                    'Sync collection view ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                ),
              )
              expect(repo.last_commit.tree).to be_a_git_tree(
                [
                  {
                    name: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        collection_views
                        ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'result' =>
                          a_hash_including(
                            'reducerResults' => {
                              'collection_group_results' =>
                                a_hash_including(
                                  'blockIds' => %w[
                                    9211601a-9016-484a-8313-f54a459a5a2a
                                    42c4bd06-12ee-4808-9624-1e7e9e7f3a5f
                                    2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a
                                  ],
                                ),
                            },
                          ),
                        'recordMap' =>
                          a_hash_including(
                            'block' =>
                              a_hash_including(
                                '9211601a-9016-484a-8313-f54a459a5a2a',
                                '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                                '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
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

  def collection_view_file_data_in(cassette_file_path)
    YAML.load_file(cassette_file_path).fetch('http_interactions')
        .find do |interaction|
        interaction.fetch('request').fetch('uri') ==
          'https://www.notion.so/api/v3/queryCollection'
      end.fetch('response')
      .fetch('body')
      .fetch('string')
  end
end
