RSpec.describe NotionCapture::GitRepoFactory do
  describe '#with_exclusive_repo' do
    context "if the lockfile doesn't exist yet" do
      context 'and the repo has not been cloned yet' do
        it 'yields a block with a decorated version of a freshly cloned repo' do
          remote_rugged_repo =
            create_rugged_repo(
              directory: remote_repo_dir,
              index: {
                'foo.txt' => 'this is a foo',
              },
              commit: true,
            )
          git_repo_factory =
            described_class.new(
              remote_url: "file://#{remote_repo_dir}",
              local_directory: local_repo_dir,
              lockfile_path: lockfile_path,
            )
          yielded_git_repo = nil

          git_repo_factory.with_exclusive_repo do |git_repo|
            yielded_git_repo = git_repo
            expect(yielded_git_repo.index.count).to be(0)
            expect(yielded_git_repo).to have_attributes(
              workdir: "#{local_repo_dir.to_s}/",
              last_commit: remote_rugged_repo.last_commit,
            )
            expect(yielded_git_repo.origin).to have_attributes(
              url: "file://#{remote_repo_dir}",
            )
          end

          expect(yielded_git_repo).to be_a(NotionCapture::GitRepo)
        end
      end

      context 'and the repo has already been cloned' do
        it 'yields a block with a decorated version of the existing repo' do
          remote_rugged_repo =
            create_rugged_repo(
              directory: remote_repo_dir,
              index: {
                'foo.txt' => 'this is a foo',
              },
              commit: true,
            )
          _local_rugged_repo =
            Rugged::Repository.clone_at(
              "file://#{remote_repo_dir}",
              local_repo_dir,
            )
          previous_ctime = File.ctime(local_repo_dir)
          git_repo_factory =
            described_class.new(
              remote_url: "file://#{remote_repo_dir}",
              local_directory: local_repo_dir,
              lockfile_path: lockfile_path,
            )
          yielded_git_repo = nil

          git_repo_factory.with_exclusive_repo do |git_repo|
            yielded_git_repo = git_repo
            expect(File.ctime(local_repo_dir)).to eq(previous_ctime)
            expect(yielded_git_repo.index.count).to be(0)
            expect(yielded_git_repo).to have_attributes(
              workdir: "#{local_repo_dir.to_s}/",
              last_commit: remote_rugged_repo.last_commit,
            )
            expect(yielded_git_repo.origin).to have_attributes(
              url: "file://#{remote_repo_dir}",
            )
          end

          expect(yielded_git_repo).to be_a(NotionCapture::GitRepo)
        end
      end
    end

    context 'if the lockfile exists already' do
      context 'if another process has a lock on the lockfile' do
        it 'waits until the lock is released before continuing' do
          _remote_rugged_repo = create_rugged_repo(directory: remote_repo_dir)
          f = File.open(lockfile_path, File::RDWR | File::CREAT)
          f.flock(File::LOCK_EX)
          git_repo_factory =
            described_class.new(
              remote_url: "file://#{remote_repo_dir}",
              local_directory: local_repo_dir,
              lockfile_path: lockfile_path,
            )

          expect do
            Timeout.timeout(2) { git_repo_factory.with_exclusive_repo {} }
          end.to raise_error(Timeout::Error)
        end
      end

      context 'if no other process has a lock on the lockfile' do
        context 'and the repo has not been cloned yet' do
          it 'yields a block with a decorated version of a freshly cloned repo' do
            remote_rugged_repo =
              create_rugged_repo(
                directory: remote_repo_dir,
                index: {
                  'foo.txt' => 'this is a foo',
                },
                commit: true,
              )
            FileUtils.touch(lockfile_path)
            git_repo_factory =
              described_class.new(
                remote_url: "file://#{remote_repo_dir}",
                local_directory: local_repo_dir,
                lockfile_path: lockfile_path,
              )
            yielded_git_repo = nil

            git_repo_factory.with_exclusive_repo do |git_repo|
              yielded_git_repo = git_repo
              expect(yielded_git_repo.index.count).to be(0)
              expect(yielded_git_repo).to have_attributes(
                workdir: "#{local_repo_dir.to_s}/",
                last_commit: remote_rugged_repo.last_commit,
              )
              expect(yielded_git_repo.origin).to have_attributes(
                url: "file://#{remote_repo_dir}",
              )
            end

            expect(yielded_git_repo).to be_a(NotionCapture::GitRepo)
          end
        end

        context 'and the repo has already been cloned' do
          it 'yields a block with a decorated version of the existing repo' do
            remote_rugged_repo =
              create_rugged_repo(
                directory: remote_repo_dir,
                index: {
                  'foo.txt' => 'this is a foo',
                },
                commit: true,
              )
            _local_rugged_repo =
              Rugged::Repository.clone_at(
                "file://#{remote_repo_dir}",
                local_repo_dir,
              )
            previous_ctime = File.ctime(local_repo_dir)
            FileUtils.touch(lockfile_path)
            git_repo_factory =
              described_class.new(
                remote_url: "file://#{remote_repo_dir}",
                local_directory: local_repo_dir,
                lockfile_path: lockfile_path,
              )
            yielded_git_repo = nil

            git_repo_factory.with_exclusive_repo do |git_repo|
              yielded_git_repo = git_repo
              expect(File.ctime(local_repo_dir)).to eq(previous_ctime)
              expect(yielded_git_repo.index.count).to be(0)
              expect(yielded_git_repo).to have_attributes(
                workdir: "#{local_repo_dir.to_s}/",
                last_commit: remote_rugged_repo.last_commit,
              )
              expect(yielded_git_repo.origin).to have_attributes(
                url: "file://#{remote_repo_dir}",
              )
            end

            expect(yielded_git_repo).to be_a(NotionCapture::GitRepo)
          end
        end
      end
    end
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local')
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote').tap { |dir| dir.mkpath }
  end

  def lockfile_path
    @lockfile_path ||= tmp_dir.join('repo-local.lock')
  end
end
