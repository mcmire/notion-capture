require_relative '../notion_capture'

FileUtils.rm_rf(NotionCapture.configuration.local_repo_dir)
FileUtils.rm_rf(NotionCapture.configuration.lockfile_path)
