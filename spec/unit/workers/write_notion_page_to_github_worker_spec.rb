RSpec.describe NotionCapture::WriteNotionPageToGithubWorker, vcr: true do
  describe '#perform' do
    it "fetches the given Notion page and stores it in the temporary Git copy (but doesn't commit anything yet)" do
      NotionCapture.with_configuration(
        remote_url: "file://#{remote_repo_dir}",
        local_directory: local_repo_dir,
      ) do
        create_rugged_repo(
          directory: remote_repo_dir,
          files: {
            'foo' => 'this is a foo',
          },
          commit: true,
        )

        # 12ba1ded-9372-45a3-adc9-ce985053d7a8 is "Test subpage"
        described_class.new.perform('12ba1ded-9372-45a3-adc9-ce985053d7a8')

        rugged_repo = Rugged::Repository.new(local_repo_dir)
        new_file_path =
          '722ba1ef-e17a-4175-90c6-dd123ddf11d4/12ba1ded-9372-45a3-adc9-ce985053d7a8.json'
        expect(rugged_repo.index.to_a).to(
          match_array(
            [
              a_hash_including(path: 'foo'),
              a_hash_including(path: new_file_path),
            ],
          ),
        )

        expect(rugged_repo.lookup(rugged_repo.index[new_file_path][:oid])).to(
          have_attributes(
            content:
              a_json_blob_including(
                'block' =>
                  a_hash_including(
                    '12ba1ded-9372-45a3-adc9-ce985053d7a8' => a_kind_of(Hash),
                  ),
              ),
          ),
        )
      end
    end
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local').tap { |dir| dir.mkpath }
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote').tap { |dir| dir.mkpath }
  end
end
