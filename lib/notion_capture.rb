require_relative "notion_capture/workers/sync_all_notion_data_with_github_worker"

module NotionCapture
  def self.run
    Workers::SyncAllNotionDataWithGithubWorker.perform_async
  end
end
