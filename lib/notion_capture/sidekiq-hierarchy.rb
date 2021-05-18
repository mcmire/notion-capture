require 'sidekiq'
require 'sidekiq-hierarchy'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Client::Middleware
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Client::Middleware
  end
  config.server_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Server::Middleware
  end
end

module NotionCapture
  class WorkflowCallback
    def call(job, status, old_status)
      if should_enqueue_github_repo_worker?(job, status)
        Workers::PersistGithubRepoWorker.perform_async
      end
    end

    private

    def should_enqueue_github_repo_worker?(job, status)
      job.info['class'] ==
        'NotionCapture::Workers::SyncAllNotionDataWithGithubWorker' &&
        status == :complete
    end
  end
end

Sidekiq::Hierarchy.callback_registry.subscribe(
  Sidekiq::Hierarchy::Notifications::WORKFLOW_UPDATE,
  NotionCapture::WorkflowCallback.new,
)
