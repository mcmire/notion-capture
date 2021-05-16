RSpec.describe NotionCapture::GithubRepo do
  describe '#page_summaries_by_id' do
    it 'returns blobs representing *.summary.json files throughout the repo as a hash of blob id => PageSummary object' do
      rugged_repo =
        create_rugged_repo(
          directory: local_repo_dir,
          files: {
            'foo.summary.json' =>
              JSON.generate(
                'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                'last_edited_time' => 1_620_017_167_711,
              ),
            'bar.summary.json' =>
              JSON.generate(
                'id' => '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                'last_edited_time' => 1_620_017_167_708,
              ),
            'foo/baz.summary.json' =>
              JSON.generate(
                'id' => '7868b070-cf4d-460e-ae6b-3c407527f7fe',
                'last_edited_time' => 1_620_017_168_434,
              ),
            'some-other-file.json' => 'some other file',
          },
          commit: true,
        )

      github_repo = described_class.new(rugged_repo)

      expect(github_repo.page_summaries_by_id).to(
        match(
          'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
            an_object_having_attributes(
              id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
            ),
          '427bbb3d-3928-4d1f-bcc0-38f7b02b4777' =>
            an_object_having_attributes(
              id: '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 7.708)),
            ),
          '7868b070-cf4d-460e-ae6b-3c407527f7fe' =>
            an_object_having_attributes(
              id: '7868b070-cf4d-460e-ae6b-3c407527f7fe',
              last_edited_time:
                a_time_around(Time.local(2021, 5, 2, 22, 46, 8.434)),
            ),
        ),
      )
    end
  end

  describe '#write_and_add' do
    it 'creates a new file at the given relative path and adds it to the index' do
      rugged_repo = create_rugged_repo(directory: local_repo_dir)
      github_repo = described_class.new(rugged_repo)

      github_repo.write_and_add('foo.txt', 'this is a foo')
      github_repo.write_and_add('foo/bar.txt', 'this is a bar')
      expect(rugged_repo.index['foo.txt']).to(be)
      expect(rugged_repo.lookup(rugged_repo.index['foo.txt'][:oid])).to(
        have_attributes(content: 'this is a foo'),
      )

      expect(rugged_repo.index['foo/bar.txt']).to(be)
      expect(rugged_repo.lookup(rugged_repo.index['foo/bar.txt'][:oid])).to(
        have_attributes(content: 'this is a bar'),
      )
    end
  end

  describe '#commit_and_push!' do
    context 'assuming that the repo can be pushed' do
      it 'creates a commit from the index and pushes the repo to the origin' do
        rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            files: {
              'foo' => 'this is a foo',
            },
            commit: true,
            origin: "file://#{remote_repo_dir}",
          )

        local_repo_dir.join('bar').write('this is a bar')
        rugged_repo.index.add_all

        Rugged::Repository.init_at(remote_repo_dir, :bare)

        github_repo = described_class.new(rugged_repo)

        github_repo.commit_and_push!

        expect(rugged_repo.last_commit).to(
          have_attributes(message: 'Automatic sync from notion-capture'),
        )
      end
    end

    context 'if the repo cannot be pushed' do
      it 'raises an error' do
        rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            files: {
              'foo' => 'this is a foo',
            },
            commit: true,
            origin: 'file:///tmp/non-existent',
          )

        github_repo = described_class.new(rugged_repo)

        expect { github_repo.commit_and_push! }.to(
          raise_error(/failed to resolve path/),
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
