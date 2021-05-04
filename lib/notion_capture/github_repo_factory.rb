require "singleton"
require "rugged"

require_relative "github_repo"

module NotionCapture
  class GithubRepoFactory
    URL = "https://github.com/mcmire/notion-backup"
    DIRECTORY = Pathname.new("/tmp/notion-archive")

    include Singleton

    def fresh_or_updated
      rugged_repo =
        (DIRECTORY.exist? && updated_rugged_repo) ||
        cloned_rugged_repo

      GithubRepo.new(rugged_repo)
    end

    def existing
      GithubRepo.new(Rugged::Repository.new(DIRECTORY))
    end

    private

    # Source: <https://github.com/libgit2/rugged/blob/003ef7134b50d35bb919e0f06e6d607906bcd0bf/test/merge_test.rb>
    def updated_rugged_repo
      repo = Rugged::Repository.new(DIRECTORY)
      repo.fetch("origin")
      ours = repo.rev_parse("main")
      theirs = repo.rev_parse("origin/main")
      analysis = repo.merge_analysis(theirs)

      if analysis == :fastforward
        base = repo.rev_parse(repo.merge_base(ours, theirs))
        index = ours.tree.merge(theirs.tree, base.tree)

        if index.conflicts?
          # repo is in a funky state - start over
          FileUtils.rm_rf(DIRECTORY)
          return nil
        else
          return repo
        end
      else
        # repo is in a funky state - start over
        FileUtils.rm_rf(DIRECTORY)
        return nil
      end
    end

    def cloned_rugged_repo
      Rugged::Repository.clone_at(URL, DIRECTORY)
    end
  end
end
