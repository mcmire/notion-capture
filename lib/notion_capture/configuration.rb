module NotionCapture
  class Configuration
    attr_accessor :remote_repo_url, :local_repo_dir, :lockfile_path

    def initialize(
      remote_repo_url: 'https://github.com/mcmire/notion-backup',
      local_repo_dir: NotionCapture::ROOT.join('tmp/notion-backup'),
      lockfile_path: NotionCapture::ROOT.join('tmp/notion-backup.lock')
    )
      self.remote_repo_url = remote_repo_url
      self.local_repo_dir = local_repo_dir
      self.lockfile_path = lockfile_path
    end
  end
end
