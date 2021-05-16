RSpec.describe NotionCapture::GithubRepoFactory do
  describe '#fresh_or_updated' do
    context 'if the repo has already been cloned' do
      context 'and the repo can be fast-forwarded to a later version' do
        it 'returns an updated version of the repo as a GithubRepo' do
          remote_rugged_repo =
            create_rugged_repo(
              directory: remote_repo_dir,
              files: {
                'foo.summary.json' =>
                  JSON.generate(
                    'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                    'last_edited_time' => 1_620_017_167_711,
                  ),
              },
              commit: true,
            )

          _local_rugged_repo =
            Rugged::Repository.clone_at(
              "file://#{remote_repo_dir}",
              local_repo_dir,
            )

          add_commit_to(
            remote_rugged_repo,
            files: {
              'bar.summary.json' =>
                JSON.generate(
                  'id' => '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                  'last_edited_time' => 1_620_017_167_708,
                ),
            },
          )

          github_repo_factory =
            described_class.new(
              remote_url: "file://#{remote_repo_dir}",
              local_directory: local_repo_dir,
            )

          expect(github_repo_factory.fresh_or_updated).to(
            have_attributes(
              page_summaries_by_id: {
                'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
                  an_object_having_attributes(
                    id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                    last_edited_time:
                      a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
                  ),
                '427bbb3d-3928-4d1f-bcc0-38f7b02b4777' =>
                  an_object_having_attributes(
                    id: '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                    last_edited_time:
                      a_time_around(Time.local(2021, 5, 2, 22, 46, 7.708)),
                  ),
              },
            ),
          )
        end
      end

      context 'but the repo cannot be fast-forwarded to a later version' do
        it 'assumes the local changes are accidental, blows them away, and returns a freshly cloned version of the repo as a GithubRepo' do
          remote_rugged_repo =
            create_rugged_repo(
              directory: remote_repo_dir,
              files: {
                'foo.summary.json' =>
                  JSON.generate(
                    'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                    'last_edited_time' => 1_620_017_167_711,
                  ),
              },
              commit: true,
            )

          local_rugged_repo =
            Rugged::Repository.clone_at(
              "file://#{remote_repo_dir}",
              local_repo_dir,
            )

          add_commit_to(
            remote_rugged_repo,
            files: {
              'bar.summary.json' =>
                JSON.generate(
                  'id' => '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                  'last_edited_time' => 1_620_017_167_708,
                ),
            },
          )

          add_commit_to(
            local_rugged_repo,
            files: {
              'baz.summary.json' =>
                JSON.generate(
                  'id' => '7868b070-cf4d-460e-ae6b-3c407527f7fe',
                  'last_edited_time' => 1_620_017_168_434,
                ),
            },
          )

          github_repo_factory =
            described_class.new(
              remote_url: "file://#{remote_repo_dir}",
              local_directory: local_repo_dir,
            )

          expect(github_repo_factory.fresh_or_updated).to(
            have_attributes(
              page_summaries_by_id: {
                'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
                  an_object_having_attributes(
                    id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                    last_edited_time:
                      a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
                  ),
                '427bbb3d-3928-4d1f-bcc0-38f7b02b4777' =>
                  an_object_having_attributes(
                    id: '427bbb3d-3928-4d1f-bcc0-38f7b02b4777',
                    last_edited_time:
                      a_time_around(Time.local(2021, 5, 2, 22, 46, 7.708)),
                  ),
              },
            ),
          )
        end
      end
    end

    context 'if the repo has not already been cloned' do
      it 'returns a cloned version of the repo as a GithubRepo' do
        _remote_rugged_repo =
          create_rugged_repo(
            directory: remote_repo_dir,
            files: {
              'foo.summary.json' =>
                JSON.generate(
                  'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                  'last_edited_time' => 1_620_017_167_711,
                ),
            },
            commit: true,
          )

        github_repo_factory =
          described_class.new(
            remote_url: "file://#{remote_repo_dir}",
            local_directory: local_repo_dir,
          )

        expect(github_repo_factory.fresh_or_updated).to(
          have_attributes(
            page_summaries_by_id: {
              'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
                an_object_having_attributes(
                  id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                  last_edited_time:
                    a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
                ),
            },
          ),
        )
      end
    end
  end

  describe '#existing' do
    it 'returns a repo that has already been cloned as a GithubRepo' do
      _local_rugged_repo =
        create_rugged_repo(
          directory: local_repo_dir,
          files: {
            'foo.summary.json' =>
              JSON.generate(
                'id' => 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                'last_edited_time' => 1_620_017_167_711,
              ),
          },
          commit: true,
        )

      github_repo_factory =
        described_class.new(
          remote_url: 'whatever',
          local_directory: local_repo_dir,
        )

      expect(github_repo_factory.existing).to(
        have_attributes(
          page_summaries_by_id: {
            'e188b9fe-c004-4ea2-b211-dc587d9ef1f4' =>
              an_object_having_attributes(
                id: 'e188b9fe-c004-4ea2-b211-dc587d9ef1f4',
                last_edited_time:
                  a_time_around(Time.local(2021, 5, 2, 22, 46, 7.711)),
              ),
          },
        ),
      )
    end
  end

  def local_repo_dir
    @local_repo_dir ||= tmp_dir.join('repo-local').tap { |dir| dir.mkpath }
  end

  def remote_repo_dir
    @remote_repo_dir ||= tmp_dir.join('repo-remote').tap { |dir| dir.mkpath }
  end
end
