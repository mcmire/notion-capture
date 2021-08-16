module Specs
  module ResourceSyncingHelpers
    def with_configuration(&block)
      NotionCapture.with_configuration(
        remote_repo_url: "file://#{remote_repo_dir}",
        local_repo_dir: local_repo_dir,
        lockfile_path: lockfile_path,
        &block
      )
    end

    def set_up_remote_repo(files:)
      create_rugged_repo(directory: remote_repo_dir, bare: true)
        .tap do |remote_rugged_repo|
        create_rugged_repo(
          directory: remote_stage_repo_dir,
          remotes: {
            'upstream' => "file://#{remote_repo_dir}",
          },
          index: files,
          commit: true,
          push_to: 'upstream',
        )
        remote_rugged_repo.head = 'refs/heads/main'
      end
    end

    def local_repo_dir
      @local_repo_dir ||= tmp_dir.join('repo-local')
    end

    def remote_stage_repo_dir
      @remote_stage_repo_dir ||= tmp_dir.join('repo-remote-stage')
    end

    def remote_repo_dir
      @remote_repo_dir ||= tmp_dir.join('repo-remote')
    end

    def lockfile_path
      @lockfile_path ||= tmp_dir.join('repo-local.lock')
    end

    def hash_with_page_block(id:, title:)
      {
        id =>
          a_hash_including(
            'value' =>
              a_hash_including(
                'id' => id,
                'properties' => a_hash_including('title' => [[title]]),
              ),
          ),
      }
    end

    def hash_with_collection_view_page_block(id:)
      { id => a_hash_including('value' => a_hash_including('id' => id)) }
    end

    def hash_with_collection(id:, name:)
      {
        id =>
          a_hash_including(
            'value' => a_hash_including('id' => id, 'name' => [[name]]),
          ),
      }
    end

    def hash_with_collection_view(id:, name:)
      {
        id =>
          a_hash_including(
            'value' => a_hash_including('id' => id, 'name' => name),
          ),
      }
    end

    def page_chunk_file_data_in(cassette_file_path, page_id:)
      data =
        YAML.load_file(cassette_file_path).fetch('http_interactions')
            .find do |interaction|
            request = interaction.fetch('request')
            request.fetch('uri') ==
              'https://www.notion.so/api/v3/loadPageChunk' &&
              JSON
                .parse(request.fetch('body').fetch('string'))
                .fetch('pageId') == page_id
          end.fetch('response')
          .fetch('body')
          .fetch('string')
      json = JSON.parse(data)
      JSON.generate(json.fetch('recordMap'))
    end

    def collection_view_file_data_in(cassette_file_path, collection_view_id:)
      YAML.load_file(cassette_file_path).fetch('http_interactions')
          .find do |interaction|
          request = interaction.fetch('request')
          request.fetch('uri') ==
            'https://www.notion.so/api/v3/queryCollection' &&
            JSON
              .parse(request.fetch('body').fetch('string'))
              .fetch('collectionViewId') == collection_view_id
        end.fetch('response')
        .fetch('body')
        .fetch('string')
    end
  end
end
