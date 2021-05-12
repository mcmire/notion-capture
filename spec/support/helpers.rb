module Specs
  module Helpers
    def tmp_dir
      @tmp_dir ||= Pathname.new("../tmp").expand_path(__dir__).tap do |dir|
        dir.rmtree if dir.exist?
      end
    end

    def create_rugged_repo(directory:, files: {}, commit: false, origin: nil)
      Rugged::Repository.init_at(directory).tap do |rugged_repo|
        if commit && !files.empty?
          add_commit_to(rugged_repo, files: files)
        end

        if origin
          rugged_repo.remotes.create("origin", origin)
        end
      end
    end

    def add_commit_to(rugged_repo, files:)
      first_commit = rugged_repo.empty?

      files.each do |name, content|
        path = Pathname.new(rugged_repo.workdir).join(name)
        path.parent.mkpath
        path.write(content)
      end

      rugged_repo.index.add_all
      new_tree_oid = rugged_repo.index.write_tree
      commit_oid = Rugged::Commit.create(
        rugged_repo,
        message: "Initial commit",
        committer: {
          name: "Nobody",
          email: "nobody@noreply.com",
          time: Time.now
        },

        author: {
          name: "Nobody",
          email: "nobody@noreply.com",
          time: Time.now
        },

        parents: first_commit ? [] : [rugged_repo.last_commit],
        tree: new_tree_oid
      )

      if rugged_repo.references.exist?("refs/heads/main")
        rugged_repo.references.update("refs/heads/main", commit_oid)
      else
        rugged_repo.branches.create("main", commit_oid)
      end

      if first_commit
        rugged_repo.head = "refs/heads/main"
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Specs::Helpers)

  config.before do
    tmp_dir.rmtree if tmp_dir.exist?
  end
end
