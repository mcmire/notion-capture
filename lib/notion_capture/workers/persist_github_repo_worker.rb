require_relative "../sidekiq"

module NotionCapture
  class PersistGithubRepoWorker
    include Sidekiq::Worker

    def initialize
      @github_repo = GithubRepoFactory.instance.existing
    end

    def perform
      github_repo.commit_and_push!
    end

    private

    attr_reader :github_repo
  end
end
