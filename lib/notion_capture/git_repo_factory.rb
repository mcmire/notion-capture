require 'rugged'

require_relative 'git_repo'

module NotionCapture
  class GitRepoFactory
    def initialize(remote_url:, local_directory:, lockfile_path:)
      @remote_url = remote_url
      @local_directory = Pathname.new(local_directory)
      @lockfile_path = Pathname.new(lockfile_path)
    end

    def with_exclusive_repo
      File.open(lockfile_path, File::RDWR | File::CREAT) do |f|
        begin
          # If multiple Sidekiq jobs are running, only let one of them access
          # the repo at one time
          f.flock(File::LOCK_EX)
          if local_directory.exist?
            rugged_repo = Rugged::Repository.new(local_directory)
          else
            rugged_repo =
              Rugged::Repository.clone_at(
                remote_url,
                local_directory,
                **repository_options,
              )
            rugged_repo.head = 'refs/heads/main'
          end
          rugged_repo.index.clear
          git_repo = GitRepo.new(rugged_repo)
          yield git_repo
        ensure
          f.flock(File::LOCK_UN)
        end
      end
    end

    private

    attr_reader :remote_url, :local_directory, :lockfile_path

    def repository_options
      if ENV.include?('GITHUB_USERNAME') && ENV.include?('GITHUB_PASSWORD')
        {
          credentials:
            Rugged::Credentials::UserPassword.new(
              {
                username: ENV['GITHUB_USERNAME'],
                password: ENV['GITHUB_PASSWORD'],
              },
            ),
        }
      else
        {}
      end
    end
  end
end
