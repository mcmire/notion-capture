require "rugged"

require_relative("github_repo")

module NotionCapture
  class GithubRepoFactory
    def initialize(remote_url:, local_directory:)
      @remote_url = remote_url
      @local_directory = Pathname.new(local_directory)
    end

    def fresh_or_updated
      @fresh_or_updated ||= GithubRepo.new(fresh_or_updated_rugged_repo)
    end

    def existing
      @existing ||= GithubRepo.new(Rugged::Repository.new(local_directory))
    end

    private

    attr_reader :remote_url, :local_directory

    def fresh_or_updated_rugged_repo
      updated_rugged_repo || cloned_rugged_repo
    end

    def updated_rugged_repo
      if local_directory.exist?
        update_rugged_repo!
      end

    rescue CannotUpdateRepoError
      nil
    rescue Rugged::RepositoryError => error
      if error.message.start_with?("could not find repository ")
        nil
      else
        raise error
      end
    end

    # Source: <https://github.com/libgit2/rugged/blob/003ef7134b50d35bb919e0f06e6d607906bcd0bf/test/merge_test.rb>
    def update_rugged_repo!
      Rugged::Repository.new(local_directory).tap do |repo|
        repo.fetch("origin")
        origin_main = repo.references["refs/remotes/origin/main"]
        analysis = repo.merge_analysis(origin_main.target)

        if analysis.include?(:normal) && analysis.include?(:fastforward)
          repo.references.update("refs/heads/main", origin_main.target.oid)
        else
          local_directory.rmtree
          raise CannotUpdateRepoError
        end
      end
    end

    def cloned_rugged_repo
      Rugged::Repository.clone_at(remote_url, local_directory)
    end

    class CannotUpdateRepoError < StandardError
    end
  end
end
