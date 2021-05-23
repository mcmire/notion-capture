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
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                722ba1ef-e17a-4175-90c6-dd123ddf11d4.json
              ].join('/'),
            content:
              content_for_notion_page('722ba1ef-e17a-4175-90c6-dd123ddf11d4'),
          },
          {
            name: '12ba1ded-9372-45a3-adc9-ce985053d7a8.json',
            path:
              %w[
                spaces
                9292b46f-54ab-41db-b39d-17436d8f8f14
                pages
                722ba1ef-e17a-4175-90c6-dd123ddf11d4
                12ba1ded-9372-45a3-adc9-ce985053d7a8.json
              ].join('/'),
            content:
              content_for_notion_page('12ba1ded-9372-45a3-adc9-ce985053d7a8'),
          },
          {
            name: 'd0bc03ce-e9c0-467e-8bba-e9814399c423.json',
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
              content_for_notion_page('d0bc03ce-e9c0-467e-8bba-e9814399c423'),
          },
        ],
      )
    end
  end

  def content_for_notion_page(page_id)
    a_json_blob_including(
      'block' =>
        a_hash_including(
          page_id =>
            a_hash_including('value' => a_hash_including('id' => page_id)),
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
