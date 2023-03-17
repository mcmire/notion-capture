RSpec.describe(
  NotionCapture::Workers::SyncAllNotionDataWithGithubWorker,
  vcr: true,
) do
  describe '#perform' do
    it 'pushes a new commit to the Git repo containing all new changes to Notion' do
      remote_rugged_repo =
        create_rugged_repo(directory: remote_repo_dir, bare: true)

      NotionCapture.with_configuration(
        remote_repo_url: "file://#{remote_repo_dir}",
        local_repo_dir: local_repo_dir,
        lockfile_path: lockfile_path,
      ) { described_class.new.perform }

      remote_rugged_repo.head = 'refs/heads/main'

      expect(remote_rugged_repo.last_commit.tree).to be_a_git_tree(
        [
          {
            name: '722ba1ef-e17a-4175-90c6-dd123ddf11d4.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                722ba1ef-e17a-4175-90c6-dd123ddf11d4.json
              ].join('/'),
            content:
              content_for_notion_page('722ba1ef-e17a-4175-90c6-dd123ddf11d4'),
          },
          {
            name: '0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                722ba1ef-e17a-4175-90c6-dd123ddf11d4
                pages
                0ecc4427-3c80-4b97-9e70-9f35ac4c5405.json
              ].join('/'),
            content:
              content_for_notion_page('0ecc4427-3c80-4b97-9e70-9f35ac4c5405'),
          },
          {
            name: '80482a7b-195b-4665-82f1-0a7825e77476.json',
            path:
              %w[
                data
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
              content_for_notion_collection_view(
                collection_view_id: '80482a7b-195b-4665-82f1-0a7825e77476',
                collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
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
                722ba1ef-e17a-4175-90c6-dd123ddf11d4
                pages
                0ecc4427-3c80-4b97-9e70-9f35ac4c5405
                collection_views
                ce55eba9-ab50-4f33-ac0d-df6ba7132973.json
              ].join('/'),
            content:
              content_for_notion_collection_view(
                collection_id: 'b12633f5-5288-4fd6-b7c9-e726780fa287',
                collection_view_id: 'ce55eba9-ab50-4f33-ac0d-df6ba7132973',
              ),
          },
          {
            name: 'd0bc03ce-e9c0-467e-8bba-e9814399c423.json',
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
                d0bc03ce-e9c0-467e-8bba-e9814399c423.json
              ].join('/'),
            content:
              content_for_notion_page('d0bc03ce-e9c0-467e-8bba-e9814399c423'),
          },
          {
            name: 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                f124cfbb-fcc5-4129-9bc2-fdad0b135fe1.json
              ].join('/'),
            content:
              content_for_notion_collection_view_page(
                id: 'f124cfbb-fcc5-4129-9bc2-fdad0b135fe1',
                collection_id: '516b47c8-a1ab-48a0-a17b-1dafd3e06009',
                collection_view_ids: ['5a900c7f-a495-4a29-b403-c8ae0356bcaa'],
              ),
          },
          {
            name: '5a900c7f-a495-4a29-b403-c8ae0356bcaa.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                collection_views
                5a900c7f-a495-4a29-b403-c8ae0356bcaa.json
              ].join('/'),
            content:
              content_for_notion_collection_view(
                collection_id: '516b47c8-a1ab-48a0-a17b-1dafd3e06009',
                collection_view_id: '5a900c7f-a495-4a29-b403-c8ae0356bcaa',
              ),
          },
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
              content_for_notion_page('2ec32fd1-d30a-4ae9-a79c-d4cc6aa0266a'),
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
              content_for_notion_page('42c4bd06-12ee-4808-9624-1e7e9e7f3a5f'),
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
              content_for_notion_page('9211601a-9016-484a-8313-f54a459a5a2a'),
          },
          {
            name: '3f98ce74-3f5d-42bd-aebd-7483b04e2a55.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                pages
                3f98ce74-3f5d-42bd-aebd-7483b04e2a55.json
              ].join('/'),
            content:
              content_for_notion_page('3f98ce74-3f5d-42bd-aebd-7483b04e2a55'),
          },
          {
            name: 'e703d132-1f20-4a0c-8959-b4077dd27acb.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                pages
                e703d132-1f20-4a0c-8959-b4077dd27acb.json
              ].join('/'),
            content:
              content_for_notion_page('e703d132-1f20-4a0c-8959-b4077dd27acb'),
          },
          {
            name: 'f4dd3fd6-e2d9-4522-841d-687c9097437e.json',
            path:
              %w[
                data
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                f124cfbb-fcc5-4129-9bc2-fdad0b135fe1
                pages
                f4dd3fd6-e2d9-4522-841d-687c9097437e.json
              ].join('/'),
            content:
              content_for_notion_page('f4dd3fd6-e2d9-4522-841d-687c9097437e'),
          },
        ],
      )
    end
  end

  def content_for_notion_page(page_id)
    a_hash_including(
      'block' =>
        a_hash_including(
          page_id =>
            a_hash_including('value' => a_hash_including('id' => page_id)),
        ),
    )
  end

  def content_for_notion_collection_view_page(
    id:,
    collection_id:,
    collection_view_ids:
  )
    a_hash_including(
      'block' =>
        a_hash_including(
          id =>
            a_hash_including(
              'value' =>
                a_hash_including(
                  'id' => id,
                  'view_ids' => collection_view_ids,
                  'collection_id' => collection_id,
                ),
            ),
        ),
    )
  end

  def content_for_notion_collection_view(collection_view_id:, collection_id:)
    a_hash_including(
      'recordMap' =>
        a_hash_including(
          'collection' =>
            a_hash_including(
              collection_id =>
                a_hash_including(
                  'value' => a_hash_including('id' => collection_id),
                ),
            ),
          # 'collection_view' =>
          # a_hash_including(
          # collection_view_id =>
          # a_hash_including(
          # 'value' => a_hash_including('id' => collection_view_id),
          # ),
          # ),
        ),
    )
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local')
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote')
  end

  def lockfile_path
    @lockfile_path ||= tmp_dir.join('repo-local.lock')
  end
end
