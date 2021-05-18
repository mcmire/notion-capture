require_relative '../sidekiq-hierarchy'

module NotionCapture
  module Workers
    class PersistGithubRepoWorker
      include Sidekiq::Worker

      def perform
        github_repo.commit_and_push!
      end

      private

      def github_repo
        @github_repo ||= NotionCapture.github_repo_factory.existing
      end
    end
  end
end
