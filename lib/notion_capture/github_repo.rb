require_relative("page_summary")

module NotionCapture
  class GithubRepo
    def initialize(rugged_repo)
      @rugged_repo = rugged_repo
    end

    def page_summaries_by_id
      search_for_blobs_by(name: /\.summary\.json/).map(&PageSummary.method(:from_git_blob)).inject({}) do |hash, page_summary|
        hash.merge(page_summary.id => page_summary)
      end
    end

    def write_and_add(file_path, content)
      File.write(File.join(rugged_repo.workdir, file_path), content)
      rugged_repo.index.add(file_path)
    end

    def commit_and_push!
      new_tree_oid = rugged_repo.index.write_tree
      person = {
        name: "notion-capture",
        email: "notion-capture@noreply.com",
        time: Time.now
      }

      commit_oid = Rugged::Commit.create(
        rugged_repo,
        message: "Automatic sync from notion-capture",
        committer: person,
        author: person,
        parents: [rugged_repo.head.target],
        tree: new_tree_oid
      )

      rugged_repo.references.update("refs/heads/main", commit_oid)

      rugged_repo.push("origin")
    end

    private

    attr_reader :rugged_repo

    def search_for_blobs_by(name:)
      # See <https://towardsdatascience.com/4-types-of-tree-traversal-algorithms-d56328450846>
      # for more on the difference between preorder and postorder traversal
      latest_commit.tree.walk(:preorder).inject([]) do |array, (root, entry)|
        if name === entry[:name]

          array + [
            BlobEntry.new(
              oid: entry[:oid],
              name: entry[:name],
              parent: root,
              rugged_repo: rugged_repo
            )
          ]
        else

          array
        end
      end
    end

    def latest_commit
      @latest_commit ||= rugged_repo.rev_parse("main")
    end

    class BlobEntry
      attr_reader :oid, :name, :parent

      def initialize(oid:, name:, parent:, rugged_repo:)
        @oid = oid
        @name = name
        @parent = parent
        @rugged_repo = rugged_repo
      end

      def full_path
        root + name
      end

      def content
        rugged_blob.content
      end

      private

      attr_reader :rugged_repo

      def rugged_blob
        @rugged_blob ||= rugged_repo.lookup(oid)
      end
    end
  end
end
