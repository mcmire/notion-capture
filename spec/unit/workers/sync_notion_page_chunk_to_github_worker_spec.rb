RSpec.describe NotionCapture::Workers::SyncNotionPageChunkToGithubWorker do
  describe '#perform' do
    context(
      'given the id of a Notion page',
      vcr: {
        cassette_name:
          'NotionCapture::Workers::SyncNotionPageChunkToGithubWorker/Test subpage',
      },
    ) do
      context 'if the Git repo does not have the given Notion page yet' do
        it 'pushes a new commit to this repo with the page, and all of its subpages, inside' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(files: { 'foo.txt' => 'this is a foo' })

            # 0ecc4427-3c80-4b97-9e70-9f35ac4c5405 is "Test subpage"
            described_class.new.perform(
              '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
              '9292b46f-54ab-41db-b39d-17436d8f8f14',
            )

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              commits = commits_for(repo)

              expect(commits).to match(
                [
                  an_object_having_attributes(
                    message:
                      'Sync collection view 80482a7b-195b-4665-82f1-0a7825e77476',
                  ),
                  an_object_having_attributes(
                    message:
                      'Sync collection view ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                  ),
                  an_object_having_attributes(
                    message: 'Sync page "Test subsubpage"',
                  ),
                  an_object_having_attributes(
                    message: 'Sync page "Test subpage"',
                  ),
                  an_object_having_attributes(message: 'Initial commit'),
                ],
              )

              expect(commits.first.tree).to be_a_git_tree(
                [
                  {
                    name: 'foo.txt',
                    path: 'foo.txt',
                    content: 'this is a foo',
                  },
                  {
                    name: '0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            hash_with_page_block(
                              id: '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                              title: 'Test subpage',
                            ),
                          ),
                      ),
                  },
                  {
                    name: '80482a7b-195b-4665-82f1-0a7825e77476.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        collection_views
                        80482a7b-195b-4665-82f1-0a7825e77476.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'recordMap' =>
                          a_hash_including(
                            'collection' =>
                              a_hash_including(
                                hash_with_collection(
                                  id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                                  name: 'Test subtable',
                                ),
                              ),
                            'collection_view' =>
                              a_hash_including(
                                hash_with_collection_view(
                                  id: '80482a7b-195b-4665-82f1-0a7825e77476',
                                  name: 'List view',
                                ),
                              ),
                          ),
                      ),
                  },
                  {
                    name: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        collection_views
                        ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'recordMap' =>
                          a_hash_including(
                            'collection' =>
                              a_hash_including(
                                hash_with_collection(
                                  id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                                  name: 'Test subtable',
                                ),
                              ),
                            'collection_view' =>
                              a_hash_including(
                                hash_with_collection_view(
                                  id: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                                  name: 'Default view',
                                ),
                              ),
                          ),
                      ),
                  },
                  {
                    name: 'd0bc03ce-e9c0-467e-8bba-e9814399c423.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        pages
                        d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            hash_with_page_block(
                              id: 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                              title: 'Test subsubpage',
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
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json
                    ].join('/') =>
                      page_chunk_file_data_in(
                        VCR.current_cassette.file,
                        page_id: '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      collection_views
                      80482a7b-195b-4665-82f1-0a7825e77476.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          '80482a7b-195b-4665-82f1-0a7825e77476',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      collection_views
                      ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                    ].join('/') =>
                      page_chunk_file_data_in(
                        VCR.current_cassette.file,
                        page_id: 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                      ),
                  },
                )
              last_commit_time = remote_rugged_repo.last_commit.time

              # 0ecc4427-3c80-4b97-9e70-9f35ac4c5405 is "Test subpage"
              described_class.new.perform(
                '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
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
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json
                    ].join('/') =>
                      JSON.generate(
                        {
                          'block' => {
                            '0ecc4427-3c80-4b97-9e70-9f35ac4c5405' => {
                              'id' => '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                              'value' => {
                                'this' => 'is different',
                              },
                            },
                          },
                        },
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      collection_views
                      80482a7b-195b-4665-82f1-0a7825e77476.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          '80482a7b-195b-4665-82f1-0a7825e77476',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      collection_views
                      ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      d0bc03ce-e9c0-467e-8bba-e9814399c423.json
                    ].join('/') =>
                      page_chunk_file_data_in(
                        VCR.current_cassette.file,
                        page_id: 'd0bc03ce-e9c0-467e-8bba-e9814399c423',
                      ),
                  },
                )

              # 0ecc4427-3c80-4b97-9e70-9f35ac4c5405 is "Test subpage"
              described_class.new.perform(
                '0ecc4427-3c80-4b97-9e70-9f35ac4c5405',
                '9292b46f-54ab-41db-b39d-17436d8f8f14',
              )

              local_rugged_repo = Rugged::Repository.new(local_repo_dir)
              [local_rugged_repo, remote_rugged_repo].each do |repo|
                expect(repo.last_commit).to(
                  have_attributes(message: 'Sync page "Test subpage"'),
                )
              end
            end
          end
        end
      end
    end

    context(
      'given the id of a Notion collection view page',
      vcr: {
        cassette_name:
          'NotionCapture::Workers::SyncNotionPageChunkToGithubWorker/Test collection view page',
      },
    ) do
      context 'if the Git repo does not have the given Notion page yet' do
        it 'pushes a new commit to this repo with the page, and all of its subpages, inside' do
          with_configuration do
            remote_rugged_repo =
              set_up_remote_repo(files: { 'foo.txt' => 'this is a foo' })

            # f124cfbb-fcc5-4129-9bc2-fdad0b135fe1 is "Test collection view page"
            described_class.new.perform(
              'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
              '9292b46f-54ab-41db-b39d-17436d8f8f14',
            )

            local_rugged_repo = Rugged::Repository.new(local_repo_dir)
            [local_rugged_repo, remote_rugged_repo].each do |repo|
              commits = commits_for(repo)

              expect(commits).to match(
                [
                  an_object_having_attributes(
                    message:
                      'Sync collection view 5a900c7f-a495-4a29-b403-c8ae0356bcaa',
                  ),
                  an_object_having_attributes(
                    message:
                      'Sync collection view page "Test collection view page"',
                  ),
                  an_object_having_attributes(message: 'Initial commit'),
                ],
              )

              expect(commits.first.tree).to be_a_git_tree(
                [
                  {
                    name: 'foo.txt',
                    path: 'foo.txt',
                    content: 'this is a foo',
                  },
                  {
                    name: 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            hash_with_collection_view_page_block(
                              id: 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                            ),
                          ),
                        'collection_view' =>
                          a_hash_including(
                            hash_with_collection_view(
                              id: '5a900c7f-a495-4a29-b403-c8ae0356bcaa',
                              name: 'Default view',
                            ),
                          ),
                        'collection' =>
                          a_hash_including(
                            hash_with_collection(
                              id: '516b47c8-a1ab-48a0-a17b-1dafd3e06009',
                              name: 'Test collection view page',
                            ),
                          ),
                      ),
                  },
                  {
                    name: '5a900c7f-a495-4a29-b403-c8ae0356bcaa.json',
                    path:
                      %w[
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                        collection_views
                        5a900c7f-a495-4a29-b403-c8ae0356bcaa.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'recordMap' =>
                          a_hash_including(
                            'collection' =>
                              a_hash_including(
                                hash_with_collection(
                                  id: '516b47c8-a1ab-48a0-a17b-1dafd3e06009',
                                  name: 'Test collection view page',
                                ),
                              ),
                            'collection_view' =>
                              a_hash_including(
                                hash_with_collection_view(
                                  id: '5a900c7f-a495-4a29-b403-c8ae0356bcaa',
                                  name: 'Default view',
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
                      f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json
                    ].join('/') =>
                      page_chunk_file_data_in(
                        VCR.current_cassette.file,
                        page_id: 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                      collection_views
                      5a900c7f-a495-4a29-b403-c8ae0356bcaa.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          '5a900c7f-a495-4a29-b403-c8ae0356bcaa',
                      ),
                  },
                )
              last_commit_time = remote_rugged_repo.last_commit.time

              # f124cfbb-fcc5-4129-9bc2-fdad0b135fe1 is "Test collection view page"
              described_class.new.perform(
                'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
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
                      f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json
                    ].join('/') =>
                      JSON.generate(
                        {
                          'block' => {
                            'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1' => {
                              'id' => 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                              'value' => {
                                'this' => 'is different',
                              },
                            },
                          },
                        },
                      ),
                    %w[
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                      collection_views
                      5a900c7f-a495-4a29-b403-c8ae0356bcaa.json
                    ].join('/') =>
                      collection_view_file_data_in(
                        VCR.current_cassette.file,
                        collection_view_id:
                          '5a900c7f-a495-4a29-b403-c8ae0356bcaa',
                      ),
                  },
                )

              # f124cfbb-fcc5-4129-9bc2-fdad0b135fe1 is "Test collection view page"
              described_class.new.perform(
                'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                '9292b46f-54ab-41db-b39d-17436d8f8f14',
              )

              local_rugged_repo = Rugged::Repository.new(local_repo_dir)
              [local_rugged_repo, remote_rugged_repo].each do |repo|
                expect(repo.last_commit).to(
                  have_attributes(
                    message:
                      'Sync collection view page "Test collection view page"',
                  ),
                )
              end
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

  def commits_for(repo)
    Rugged::Walker.walk(
      repo,
      show: repo.last_commit.oid,
      sort: Rugged::SORT_DATE | Rugged::SORT_TOPO,
    ).to_a
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

  def hash_with_page_block(id:, title:)
    {
      id =>
        a_hash_including(
          'value' =>
            a_hash_including(
              'id' => id,
              'properties' => {
                'title' => [[title]],
              },
            ),
        ),
    }
  end

  def hash_with_collection_view_page_block(id:)
    { id => a_hash_including('value' => a_hash_including('id' => id)) }
  end

  def hash_with_collection(id:, name:)
    {
      id =>
        a_hash_including(
          'value' => a_hash_including('id' => id, 'name' => [[name]]),
        ),
    }
  end

  def hash_with_collection_view(id:, name:)
    {
      id =>
        a_hash_including(
          'value' => a_hash_including('id' => id, 'name' => name),
        ),
    }
  end

  def page_chunk_file_data_in(cassette_file_path, page_id:)
    data =
      YAML.load_file(cassette_file_path).fetch('http_interactions')
          .find do |interaction|
          request = interaction.fetch('request')
          request.fetch('uri') ==
            'https://www.notion.so/api/v3/loadPageChunk' &&
            JSON.parse(request.fetch('body').fetch('string')).fetch('pageId') ==
              page_id
        end.fetch('response')
        .fetch('body')
        .fetch('string')
    json = JSON.parse(data)
    JSON.generate(json.fetch('recordMap'))
  end

  def collection_view_file_data_in(cassette_file_path, collection_view_id:)
    YAML.load_file(cassette_file_path).fetch('http_interactions')
        .find do |interaction|
        request = interaction.fetch('request')
        request.fetch('uri') ==
          'https://www.notion.so/api/v3/queryCollection' &&
          JSON
            .parse(request.fetch('body').fetch('string'))
            .fetch('collectionViewId') == collection_view_id
      end.fetch('response')
      .fetch('body')
      .fetch('string')
  end
end
