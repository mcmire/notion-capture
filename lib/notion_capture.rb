require_relative("notion_capture/configuration")
require_relative("notion_capture/workers/sync_all_notion_data_with_github_worker")

module NotionCapture
  ROOT = Pathname.new("..").expand_path(__dir__)

  singleton_class.attr_writer :configuration

  def self.run
    Workers::SyncAllNotionDataWithGithubWorker.perform_async
  end

  def self.github_repo_factory
    @github_repo_factory ||= GithubRepoFactory.new(
      remote_url: configuration.remote_url,
      local_directory: configuration.local_directory
    )
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.with_configuration(**options)
    previous_configuration = configuration
    self.configuration = Configuration.new(**options)
    yield

    self.configuration = previous_configuration
  end
end
