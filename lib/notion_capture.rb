require_relative("notion_capture/workers/sync_all_notion_data_with_github_worker")

module NotionCapture
  ROOT = Pathname.new("..").expand_path(__dir__)

  def self.run
    Workers::SyncAllNotionDataWithGithubWorker.perform_async
  end

  def self.github_repo_factory
    @github_repo_factory ||= GithubRepoFactory.new(
      remote_url: "https://github.com/mcmire/notion-backup",
      local_directory: ROOT.join("tmp/notion-backup")
    )
  end
end
