RSpec.describe(
  NotionCapture::Workers::SyncAllNotionDataWithGithubWorker,
  vcr: true,
) do
  describe '#perform' do
    it 'pushes a new commit to the Git repo containing all new changes to Notion' do
      remote_rugged_repo =
        create_rugged_repo(directory: remote_repo_dir, bare: true)

      NotionCapture.with_configuration(
        remote_url: "file://#{remote_repo_dir}",
        local_directory: local_repo_dir,
      ) { described_class.new.perform }

      remote_rugged_tree =
        remote_rugged_repo.references['refs/heads/main'].target.tree
      actual_blobs = read_blobs_from(remote_rugged_tree, remote_rugged_repo)
      expected_paths = %w[
        03be1b94-12ac-4bc3-be3d-ea2e30d02197
        265cf337-46a0-4300-a89a-2b10889efbca
        5a6eabf3-2a2d-439d-968b-8435c91a754a
        722ba1ef-e17a-4175-90c6-dd123ddf11d4
        8d367ce1-db33-4367-8088-243c877c2954
        96906133-ad6c-4883-b1b3-f308ab59c3a8
        9af6fc30-4316-4c2b-9958-632c857a20d7
      ]
      expected_blobs =
        expected_paths.map do |path|
          page_id = path.split('/').last
          a_hash_including(
            name: "#{path}.json",
            path: "#{path}.json",
            content:
              a_json_blob_including(
                'block' =>
                  a_hash_including(
                    page_id =>
                      a_hash_including(
                        'role' => a_kind_of(String),
                        'value' => a_hash_including('id' => page_id),
                      ),
                  ),
              ),
          )
        end
      expect(actual_blobs).to match(expected_blobs)
    end
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local')
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote').tap { |dir| dir.mkpath }
  end

  def remote_clone_repo_dir
    @remote_clone_repo_dir ||= tmp_dir.join('repo-remote-clone')
  end

  def read_blobs_from(rugged_tree, rugged_repo)
    rugged_tree
      .walk(:preorder)
      .inject([]) do |array, (root, entry)|
        if entry[:type] == :blob
          array + [
            {
              name: entry[:name],
              path: root + entry[:name],
              content: rugged_repo.lookup(entry[:oid]).content,
            },
          ]
        else
          array
        end
      end
  end
end
