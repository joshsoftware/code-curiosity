require 'test_helper'

class CommitsFetcherTest < ActiveSupport::TestCase
  def setup
    super
    file_path = 'test/fixtures/commits.json'
    @commits = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    Timecop.freeze(Time.parse(@commits.first.commit.committer.date))
    @user = create :user, github_handle: 'prasadsurase'
    @repo = create :repository, name: 'code-curiosity', ssh_url: 'git@github.com:prasadsurase/code-curiosity.git', owner: 'prasadsurase'
    @round = create :round, :open, from_date: @commits.collect{|i| Time.parse i.commit.committer.date}.min.beginning_of_month

    stub_get('/repos/prasadsurase/code-curiosity').to_return(
      body: File.read('test/fixtures/repo.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

  def teardown
    super
    Timecop.return
  end

  test 'fetch daily' do
    Github::Client::Repos.any_instance.stubs(:branches).returns(['master'])
    CommitsFetcher.any_instance.stubs(:branch_commits).with('master').returns(true)
    commits_fetcher = CommitsFetcher.new(@repo, @user, @round)
    commits_fetcher.fetch(:daily)
    assert_equal 0, Commit.count
  end

  test 'fetch all' do
    Github::Client::Repos.any_instance.stubs(:branches).returns(['master'])
    CommitsFetcher.any_instance.stubs(:branch_commits).with('master', :all).returns(true)
    commits_fetcher = CommitsFetcher.new(@repo, @user, @round)
    commits_fetcher.fetch(:all)
    assert_equal 0, Commit.count
    commits_fetcher = CommitsFetcher.new(@repo, @user, @round)
    commits_fetcher.fetch(:all)
  end

  test 'creates commits for daily run' do
    branch = Hashie::Mash.new({
      commit: {
        url: 'https://api.github.com/repos/prasadsurase/code-curiosity/commits/753c94d1eb2712349ee719efe6c4934f8b9f4d3d',
        sha: '753c94d1eb2712349ee719efe6c4934f8b9f4d3d'
      },
      name: 'master'
    })
    file_path = 'test/fixtures/commit-daily.json'
    @commits = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    Timecop.freeze(Time.parse(@commits.first.commit.committer.date))
    Github::Client::Repos.any_instance.stubs(:branches).returns([branch])
    assert_equal 1, @commits.select{|i| i.commit.author.date >= (Time.now - 30.hours)}.count
    query_params = { author: 'prasadsurase', sha: 'master', since: (Time.now - 30.hours), 'until' => @round.end_date.end_of_day }
    stub_get('/repos/prasadsurase/code-curiosity/commits').with(query: query_params).to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )

    commits_fetcher = CommitsFetcher.new(@repo, @user, @round)
    commits_fetcher.fetch(:daily)
    assert_equal 1, Commit.count
    commit = Commit.first
    data = @commits.select{|i| i.commit.author.date >= (Time.now - 30.hours)}.first
    assert_equal data.commit.message, commit.message
    assert_equal data.commit.author.date.to_datetime, commit.commit_date
    assert_equal @user, commit.user
    assert_equal @repo, commit.repository
    assert_equal data.html_url, commit.html_url
    assert_equal data.commit.comment_count, commit.comments_count
    assert_equal @repo.organization_id, commit.organization_id
  end

  test 'creates commits for current round' do
    branch = Hashie::Mash.new({
      commit: {
        url: 'https://api.github.com/repos/prasadsurase/code-curiosity/commits/753c94d1eb2712349ee719efe6c4934f8b9f4d3d',
        sha: '753c94d1eb2712349ee719efe6c4934f8b9f4d3d'
      },
      name: 'master'
    })
    file_path = 'test/fixtures/commits.json'
    @commits = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}

    query_params = { author: 'prasadsurase', sha: 'master', since: @round.from_date.beginning_of_day, 'until' => @round.end_date.end_of_day }
    stub_get('/repos/prasadsurase/code-curiosity/commits').with(query: query_params).to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )

    Github::Client::Repos.any_instance.stubs(:branches).returns([branch])
    assert_equal 17, @commits.select{|i| i.commit.author.date >= @round.from_date.beginning_of_day}.count
    commits_fetcher = CommitsFetcher.new(@repo, @user, @round)
    commits_fetcher.fetch(:all)
    assert_equal 17, Commit.count
  end
end
