require 'forwardable'

module NotionCapture
  class GitRepo
    extend Forwardable

    delegate %i[index workdir] => :rugged_repo

    def initialize(rugged_repo)
      @rugged_repo = rugged_repo
    end

    def origin
      rugged_repo.remotes['origin']
    end

    def last_commit
      rugged_repo.last_commit
    rescue Rugged::ReferenceError
      nil
    end

    def push_file!(file_path, content)
      initialize_index!
      write(file_path, content)
      add_to_index(file_path)
      commit
      push
    end

    def find_file!(file_path)
      if last_commit
        tree = last_commit.tree

        file_path
          .split('/')
          .each do |path_part|
            entry = tree[path_part]

            if entry
              if entry[:type] == :tree
                tree = rugged_repo.lookup(entry[:oid])
              elsif entry[:type] == :blob
                return GitFile.new(rugged_repo.lookup(entry[:oid]), file_path)
              else
                raise "Unsupported entry type #{entry[:type].inspect}"
              end
            else
              return nil
            end
          end
      else
        nil
      end
    end

    private

    attr_reader :rugged_repo

    def initialize_index!
      if rugged_repo.index.count > 0
        raise 'Please clear the index before calling #push_file!.'
      end

      # Stolen from gollum_rails: <https://github.com/GBCarpiArtStudio/gollum_rails/blob/73035c08474741d277e553001483e614dc2f629d/lib/gollum_rails/wiki.rb>
      rugged_repo.index.read_tree(last_commit.tree) if last_commit
    end

    def write(file_path, content)
      full_path = File.join(rugged_repo.workdir, file_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
    end

    def add_to_index(file_path)
      rugged_repo.index.add(file_path)
      rugged_repo.index.write
    end

    def commit
      new_tree_oid = rugged_repo.index.write_tree
      rugged_repo.index.clear
      first_commit = rugged_repo.empty?
      person = {
        name: 'notion-capture',
        email: 'notion-capture@noreply.com',
        time: Time.now,
      }
      parents = last_commit ? [last_commit] : []
      commit_oid =
        Rugged::Commit.create(
          rugged_repo,
          message: 'Automatic sync from notion-capture',
          committer: person,
          author: person,
          parents: parents,
          tree: new_tree_oid,
        )
      if rugged_repo.references.exist?('refs/heads/main')
        rugged_repo.references.update('refs/heads/main', commit_oid)
      else
        rugged_repo.branches.create('main', commit_oid)
        rugged_repo.head = 'refs/heads/main' if first_commit
      end
    end

    def push
      rugged_repo.remotes['origin'].push(
        %w[refs/heads/main:refs/heads/main],
        **push_options,
      )
    end

    def push_options
      if NotionCapture.rugged_credentials
        { credentials: NotionCapture.rugged_credentials }
      else
        {}
      end
    end

    class GitFile
      attr_reader :path

      def initialize(rugged_blob, path)
        @rugged_blob = rugged_blob
        @path = path
      end

      def oid
        rugged_blob.oid
      end

      def content
        rugged_blob.content
      end

      attr_reader :rugged_blob
    end
  end
end
