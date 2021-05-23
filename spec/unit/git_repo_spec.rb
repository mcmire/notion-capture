RSpec.describe NotionCapture::GitRepo do
  describe '#push_file!' do
    context 'if something is already in the index' do
      it 'raises an error' do
        local_rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            remotes: {
              origin: "file://#{remote_repo_dir}",
            },
            index: {
              'foo.txt' => 'this is a foo',
            },
          )
        _remote_rugged_repo = Rugged::Repository.init_at(remote_repo_dir, :bare)
        git_repo = described_class.new(local_rugged_repo)

        expect {
          git_repo.push_file!('bar.txt', 'this is a bar')
        }.to raise_error('Please clear the index before calling #push_file!.')
      end
    end

    context 'assuming that nothing is already in the index' do
      context 'assuming that the repo can be pushed' do
        context 'assuming the remote repo has a main branch' do
          it 'creates a new commit with the given file and pushes it to the origin' do
            local_rugged_repo =
              create_rugged_repo(
                directory: local_repo_dir,
                remotes: {
                  origin: "file://#{remote_repo_dir}",
                },
                index: {
                  'foo.txt' => 'this is a foo',
                },
                commit: true,
              )
            remote_rugged_repo =
              Rugged::Repository.init_at(remote_repo_dir, :bare)
            git_repo = described_class.new(local_rugged_repo)

            git_repo.push_file!('bar.txt', 'this is a bar')

            last_commit =
              remote_rugged_repo.references['refs/heads/main'].target
            expect(last_commit).to(
              have_attributes(
                message: 'Automatic sync from notion-capture',
                tree:
                  an_object_having_attributes(
                    to_a:
                      an_array_matching(
                        [
                          a_hash_including(name: 'foo.txt'),
                          a_hash_including(name: 'bar.txt'),
                        ],
                      ),
                  ),
              ),
            )
            expect(
              remote_rugged_repo.lookup(last_commit.tree['foo.txt'][:oid]),
            ).to have_attributes(content: 'this is a foo')
            expect(
              remote_rugged_repo.lookup(last_commit.tree['bar.txt'][:oid]),
            ).to have_attributes(content: 'this is a bar')
          end
        end

        context "if the local repo doesn't have a main branch yet" do
          it 'creates a new main branch, makes a new commit with the given file, and pushes it to the origin' do
            local_rugged_repo =
              create_rugged_repo(
                directory: local_repo_dir,
                remotes: {
                  origin: "file://#{remote_repo_dir}",
                },
              )
            remote_rugged_repo =
              Rugged::Repository.init_at(remote_repo_dir, :bare)
            git_repo = described_class.new(local_rugged_repo)

            git_repo.push_file!('foo.txt', 'this is a foo')

            last_commit =
              remote_rugged_repo.references['refs/heads/main'].target
            expect(last_commit).to(
              have_attributes(
                message: 'Automatic sync from notion-capture',
                tree:
                  an_object_having_attributes(
                    to_a:
                      an_array_matching([a_hash_including(name: 'foo.txt')]),
                  ),
              ),
            )
            expect(
              remote_rugged_repo.lookup(last_commit.tree['foo.txt'][:oid]),
            ).to have_attributes(content: 'this is a foo')
          end
        end
      end

      context 'if the repo cannot be pushed for some reason (e.g. the origin is invalid)' do
        it 'raises an error' do
          local_rugged_repo =
            create_rugged_repo(
              directory: local_repo_dir,
              remotes: {
                origin: 'file:///tmp/non-existent',
              },
              index: {
                'foo' => 'this is a foo',
              },
              commit: true,
            )
          git_repo = described_class.new(local_rugged_repo)

          expect { git_repo.push_file!('foo.txt', 'this is a foo') }.to(
            raise_error(/failed to resolve path/),
          )
        end
      end
    end
  end

  describe '#find_file!' do
    context "assuming the given path refers to a file in the repo's latest commit" do
      it 'returns an object representing that file' do
        rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            index: {
              'foo/bar.txt' => 'this is a foo bar',
            },
            commit: true,
          )
        git_repo = described_class.new(rugged_repo)

        expect(git_repo.find_file!('foo/bar.txt')).to have_attributes(
          oid: '318976d4b7b728113341c022fa1ea4bed4579cfc',
          content: 'this is a foo bar',
        )
      end
    end

    context "if any part of the given path cannot be found in the repo's latest commit" do
      it 'returns nil' do
        rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            index: {
              'foo/bar.txt' => 'this is a foo bar',
            },
            commit: true,
          )
        git_repo = described_class.new(rugged_repo)

        expect(git_repo.find_file!('foo/baz.txt')).to be(nil)
        expect(git_repo.find_file!('qux')).to be(nil)
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
