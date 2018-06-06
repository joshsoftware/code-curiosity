require 'test_helper'

class GitFetcherTest < ActiveSupport::TestCase
  before do
    options = {
      repo_owner: 'pain11',
      repo_name: 'Facebook'
    }
    @git_fetcher = GitFetcher.new(**options)
    create :repository, name: 'Facebook', owner: 'pain11'
  end

  describe 'fetch commits' do
    describe 'commits are present' do
      before do
        GitFetcher.any_instance.stubs(:fetch_commits).returns(
          JSON.parse(File.read('test/fixtures/git_commit.json'))
        )
        GitFetcher.any_instance.stubs(:fetch_pull_request).returns(
          Hashie::Mash.new(
            JSON.parse(File.read('test/fixtures/pull_request.json'))
          )
        )
      end

      test 'do not create commit if Committer is not present in code-curiosity' do
        assert_equal 0, Commit.count
        assert_equal 1, @git_fetcher.fetch_and_store_commits.count
        assert_equal 0, Commit.count
      end

      describe 'Committer is present in code-curiosity' do
        before do
          @user = create(
                    :user,
                    email: 'rahul.rj9421@gmail.com',
                    created_at: Date.parse('2018-02-04')
                  )
        end

        test 'create commits which are committed after sign up' do
          assert_equal 0, Commit.count
          @git_fetcher.fetch_and_store_commits
          assert_equal 1, Commit.count
        end

        test 'create pull request associated with commit if present' do
          assert_equal 0, PullRequest.count
          @git_fetcher.fetch_and_store_commits
          assert_equal 1, Commit.count
          assert_equal 1, PullRequest.count
        end

        test 'do not create pull request associated with commit if not present' do
          GitFetcher.any_instance.stubs(:fetch_pull_request).returns(nil)
          assert_equal 0, PullRequest.count
          @git_fetcher.fetch_and_store_commits
          assert_equal 1, Commit.count
          assert_equal 0, PullRequest.count
        end

        test 'do not create commits which are commmitted before sign up' do
          @user.set(created_at: Date.today)
          assert_equal 0, Commit.count
          assert_equal 1, @git_fetcher.fetch_and_store_commits.count
          assert_equal 0, Commit.count
        end
      end
    end

    describe 'commits are not present' do
      test 'do not create commit records' do
        GitFetcher.any_instance.stubs(:fetch_commits).returns([])
        assert_equal 0, Commit.count
        @git_fetcher.fetch_and_store_commits
        assert_equal 0, Commit.count
      end
    end
  end
end
