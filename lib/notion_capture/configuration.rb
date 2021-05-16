module NotionCapture
  class Configuration
    attr_accessor :remote_url, :local_directory

    def initialize(
      remote_url: "https://github.com/mcmire/notion-backup",
      local_directory: NotionCapture::ROOT.join("tmp/notion-backup")
    )
      self.remote_url = remote_url
      self.local_directory = local_directory
    end
  end
end
