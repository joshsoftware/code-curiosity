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
    
  describe 'Commits found for given date range' do
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

    describe 'Committer is not present in code-curiosity' do
      test 'do not create commit record' do
        assert_equal 0, Commit.count
        @git_fetcher.fetch_and_store_commits
        assert_equal 0, Commit.count
      end
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

      describe 'commit has pull request associated with it' do
        test 'should create pull request' do
          assert_equal 0, PullRequest.count
          @git_fetcher.fetch_and_store_commits
          assert_equal 1, Commit.count
          assert_equal 1, PullRequest.count
        end
      end

      describe 'commit has no pull request associated with it' do
        test 'should not create pull request' do
          GitFetcher.any_instance.stubs(:fetch_pull_request).returns(nil)
          assert_equal 0, PullRequest.count
          @git_fetcher.fetch_and_store_commits
          assert_equal 1, Commit.count
          assert_equal 0, PullRequest.count
        end
      end

      test 'do not create commits which are commmitted before sign up' do
        @user.set(created_at: Date.today)
        assert_equal 0, Commit.count
        @git_fetcher.fetch_and_store_commits
        assert_equal 0, Commit.count
      end
    end
  end

  describe 'Commits not found for given date range' do
    test 'do not create commit record' do
      GitFetcher.any_instance.stubs(:fetch_commits).returns([])
      assert_equal 0, Commit.count
      @git_fetcher.fetch_and_store_commits
      assert_equal 0, Commit.count
    end
  end
end
