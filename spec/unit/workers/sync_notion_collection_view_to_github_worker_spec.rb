RSpec.describe NotionCapture::Workers::SyncNotionCollectionViewToGithubWorker do
  include Specs::ResourceSyncingHelpers

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
            commits = commits_for(repo)

            expect(commits).to match(
              [
                an_object_having_attributes(message: 'Sync page "Joe"'),
                an_object_having_attributes(message: 'Sync page "Sally"'),
                an_object_having_attributes(message: 'Sync page "Steve"'),
                an_object_having_attributes(
                  message:
                    'Sync collection view ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                ),
                an_object_having_attributes(message: 'Initial commit'),
              ],
            )

            expect(commits.first.tree).to be_a_git_tree(
              [
                { name: 'foo.txt', path: 'foo.txt', content: 'this is a foo' },
                {
                  name: '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json',
                  path:
                    %w[
                      data
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      227fd83a-546c-48f2-abde-14a08c43faae
                      pages
                      2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json
                    ].join('/'),
                  content:
                    a_hash_including(
                      'block' =>
                        a_hash_including(
                          '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
                        ),
                    ),
                },
                {
                  name: '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json',
                  path:
                    %w[
                      data
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      227fd83a-546c-48f2-abde-14a08c43faae
                      pages
                      42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json
                    ].join('/'),
                  content:
                    a_hash_including(
                      'block' =>
                        a_hash_including(
                          '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                        ),
                    ),
                },
                {
                  name: '9211601a-9016-484a-8313-f54a459a5a2a.json',
                  path:
                    %w[
                      data
                      spaces
                      9292b46f-54ab-41db-b39d-17436d8f8f14
                      pages
                      722ba1ef-e17a-4175-90c6-dd123ddf11d4
                      pages
                      0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                      pages
                      227fd83a-546c-48f2-abde-14a08c43faae
                      pages
                      9211601a-9016-484a-8313-f54a459a5a2a.json
                    ].join('/'),
                  content:
                    a_hash_including(
                      'block' =>
                        a_hash_including(
                          '9211601a-9016-484a-8313-f54a459a5a2a',
                        ),
                    ),
                },
                # TODO: These paths are wrong!!
                # It should be 722ba1ef-e17a-4175-90c6-dd123ddf11d4 -> 0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                # not 0ecc4427-3c80-4b97-9e70-9f35ac4c5405 -> 722ba1ef-e17a-4175-90c6-dd123ddf11d4
                {
                  name: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973.json',
                  path:
                    %w[
                      data
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
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    collection_views
                    ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
                  ].join('/') =>
                    collection_view_file_data_in(
                      VCR.current_cassette.file,
                      collection_view_id:
                        'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
                    ),
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
                    ),
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                    ),
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    9211601a-9016-484a-8313-f54a459a5a2a.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '9211601a-9016-484a-8313-f54a459a5a2a',
                    ),
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
                    data
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
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
                    ),
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                    ),
                  %w[
                    data
                    spaces
                    9292b46f-54ab-41db-b39d-17436d8f8f14
                    pages
                    722ba1ef-e17a-4175-90c6-dd123ddf11d4
                    pages
                    0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                    pages
                    227fd83a-546c-48f2-abde-14a08c43faae
                    pages
                    9211601a-9016-484a-8313-f54a459a5a2a.json
                  ].join('/') =>
                    page_chunk_file_data_in(
                      VCR.current_cassette.file,
                      page_id: '9211601a-9016-484a-8313-f54a459a5a2a',
                    ),
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
                    name: '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json',
                    path:
                      %w[
                        data
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        pages
                        227fd83a-546c-48f2-abde-14a08c43faae
                        pages
                        2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            '2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a',
                          ),
                      ),
                  },
                  {
                    name: '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json',
                    path:
                      %w[
                        data
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        pages
                        227fd83a-546c-48f2-abde-14a08c43faae
                        pages
                        42c4bd06-12ee-4808-9624-1e7e9e7f3a5f.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            '42c4bd06-12ee-4808-9624-1e7e9e7f3a5f',
                          ),
                      ),
                  },
                  {
                    name: '9211601a-9016-484a-8313-f54a459a5a2a.json',
                    path:
                      %w[
                        data
                        spaces
                        9292b46f-54ab-41db-b39d-17436d8f8f14
                        pages
                        722ba1ef-e17a-4175-90c6-dd123ddf11d4
                        pages
                        0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                        pages
                        227fd83a-546c-48f2-abde-14a08c43faae
                        pages
                        9211601a-9016-484a-8313-f54a459a5a2a.json
                      ].join('/'),
                    content:
                      a_hash_including(
                        'block' =>
                          a_hash_including(
                            '9211601a-9016-484a-8313-f54a459a5a2a',
                          ),
                      ),
                  },
                  {
                    name: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973.json',
                    path:
                      %w[
                        data
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
end
