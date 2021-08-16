module Specs
  module RuggedHelpers
    def self.add_to_example_groups(config)
      config.include(self)
      config.before { tmp_dir.rmtree if tmp_dir.exist? }
    end

    def tmp_dir
      @tmp_dir ||=
        Pathname
          .new('../tmp')
          .expand_path(__dir__)
          .tap { |dir| dir.rmtree if dir.exist? }
    end

    def create_rugged_repo(
      directory:,
      bare: false,
      remotes: {},
      index: {},
      commit: false,
      push_to: nil
    )
      Rugged::Repository
        .init_at(directory, bare)
        .tap do |rugged_repo|
          add_files_to_index(rugged_repo, index) if !index.empty?
          create_commit_from_index_of(rugged_repo) if commit && !index.empty?
          remotes.each do |name, url|
            rugged_repo.remotes.create(name.to_s, url)
          end
          push_to_remote(rugged_repo, push_to) if push_to
        end
    end

    def commits_for(repo)
      Rugged::Walker.walk(
        repo,
        show: repo.last_commit.oid,
        sort: Rugged::SORT_DATE | Rugged::SORT_TOPO,
      ).to_a
    end

    private

    def add_files_to_index(rugged_repo, files)
      files.each do |name, content|
        path = Pathname.new(rugged_repo.workdir || rugged_repo.path).join(name)
        path.parent.mkpath
        path.write(content)
        rugged_repo.index.add(name)
        rugged_repo.index.write
      end
    end

    def create_commit_from_index_of(rugged_repo)
      first_commit = rugged_repo.empty?

      new_tree_oid = rugged_repo.index.write_tree
      rugged_repo.index.clear
      now = Time.now
      commit_oid =
        Rugged::Commit.create(
          rugged_repo,
          message: 'Initial commit',
          committer: {
            name: 'Nobody',
            email: 'nobody@noreply.com',
            time: now,
          },
          author: {
            name: 'Nobody',
            email: 'nobody@noreply.com',
            time: now,
          },
          parents: first_commit ? [] : [rugged_repo.last_commit],
          tree: new_tree_oid,
        )

      if rugged_repo.references.exist?('refs/heads/main')
        rugged_repo.references.update('refs/heads/main', commit_oid)
      else
        rugged_repo.branches.create('main', commit_oid)
      end

      rugged_repo.head = 'refs/heads/main' if first_commit
    end

    def push_to_remote(rugged_repo, remote_name)
      rugged_repo.remotes[remote_name].push(%w[refs/heads/main:refs/heads/main])
    end
  end
end

RSpec.configure { |config| Specs::RuggedHelpers.add_to_example_groups(config) }
