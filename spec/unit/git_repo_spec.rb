RSpec.describe NotionCapture::GitRepo do
  describe '#pushing_commit!' do
    context 'assuming that nothing is already in the index initially' do
      context 'assuming that something gets put in the index' do
        context 'assuming that the repo can be pushed' do
          context "assuming that the local repo doesn't have a main branch yet" do
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

              git_repo.pushing_commit!('This is the message') do
                git_repo.create_file_in_index!('foo.txt', 'this is a foo')
              end

              last_commit =
                remote_rugged_repo.references['refs/heads/main'].target
              expect(last_commit).to(
                have_attributes(
                  message: 'This is the message',
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
          context 'if the remote repo already has a main branch' do
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

              git_repo.pushing_commit!('This is the message') do
                git_repo.create_file_in_index!('bar.txt', 'this is a bar')
              end

              last_commit =
                remote_rugged_repo.references['refs/heads/main'].target
              expect(last_commit).to(
                have_attributes(
                  message: 'This is the message',
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
        end

        context 'if the repo cannot be pushed for some reason (e.g. the origin is invalid)' do
          it 'raises an error' do
            local_rugged_repo =
              create_rugged_repo(
                directory: local_repo_dir,
                remotes: {
                  origin: 'file:///tmp/non-existent',
                },
              )
            git_repo = described_class.new(local_rugged_repo)

            expect do
              git_repo.pushing_commit!('This is the message') do
                git_repo.create_file_in_index!('foo.txt', 'this is a foo')
              end
            end.to(raise_error(/failed to resolve path/))
          end
        end
      end

      context 'if nothing gets put in the index' do
        it 'raises an error' do
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

          expect do
            git_repo.pushing_commit!('This is the message') {}
          end.to raise_error('Nothing to commit: index empty.')
        end
      end
    end

    context 'if something is already in the index initially' do
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
          git_repo.pushing_commit!('This is the message') {}
        }.to raise_error(
          'Please clear the index before calling #pushing_commit!.',
        )
      end
    end
  end

  describe '#create_file_in_index!' do
    context 'assuming that the given file path does not exist in the repo workdir' do
      it 'creates the given file and adds it to the index' do
        local_rugged_repo = create_rugged_repo(directory: local_repo_dir)
        git_repo = described_class.new(local_rugged_repo)

        git_repo.create_file_in_index!('foo.txt', 'this is a foo')

        expect(local_rugged_repo).to have_index(
          [{ path: 'foo.txt', content: 'this is a foo' }],
        )
      end
    end

    context 'if the given file path already exists in the repo workdir' do
      it 'overwrites the given file and adds it to the index' do
        local_rugged_repo =
          create_rugged_repo(
            directory: local_repo_dir,
            index: {
              'foo.txt' => 'this is a foo',
            },
          )
        git_repo = described_class.new(local_rugged_repo)

        git_repo.create_file_in_index!('foo.txt', 'this is a bar')

        expect(local_rugged_repo).to have_index(
          [{ path: 'foo.txt', content: 'this is a bar' }],
        )
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
