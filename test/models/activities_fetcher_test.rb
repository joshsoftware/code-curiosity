require 'test_helper'

class ActivitiesFetcherTest < ActiveSupport::TestCase
  def setup
    super
    @activities = JSON.parse(File.read('test/fixtures/activities.json'))
    Timecop.freeze(Time.parse @activities[1].fetch('created_at'))
    @user = create :user, github_handle: 'prasadsurase'
    @round = create :round, :open, from_date: @activities.collect{|i| Time.parse i['created_at']}.min.beginning_of_month
    stub_get('/users/prasadsurase/events?per_page=200').to_return(
      body: File.read('test/fixtures/activities.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )

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
    activities_fetcher = ActivitiesFetcher.new(@user, @round)
    activities_fetcher.fetch(:daily)
    assert_equal 1, Activity.count
    assert_equal 1, Repository.count
  end

  test 'fetch all' do
    activities_fetcher = ActivitiesFetcher.new(@user, @round)
    activities_fetcher.fetch(:all)
    assert_equal 2, Activity.count
    assert_equal 1, Repository.count
  end

  test 'creates activity' do
    activities_fetcher = ActivitiesFetcher.new(@user, @round)
    activities_fetcher.fetch(:all)
    assert_equal 2, Activity.count
    activity = Activity.first
    json_data = @activities[1]
    assert_equal activity.gh_id, json_data['id']
    assert_equal activity.event_type, ActivitiesFetcher::TRACKING_EVENTS[json_data.fetch('type')]
    assert_equal activity.repo, json_data['repo']['name']
    assert_equal activity.ref_url, json_data['payload']['comment']['html_url']
    assert_equal activity.commented_on, Time.parse(json_data['created_at'])
    assert_equal activity.round, @round
    assert_equal activity.user, @user
    assert_equal activity.repository, Repository.last
    assert_equal activity.organization_id, Repository.last.organization_id
  end

  test 'creates repo if not present' do
    activities_fetcher = ActivitiesFetcher.new(@user, @round)
    activities_fetcher.fetch(:all)
    assert_equal 2, Activity.count
    assert_equal 1, Repository.count
    repository = Repository.last
    data = @activities[1]['repo']
    assert_equal data['name'].split('/').last, repository.name
    assert_equal 25, repository.stars
    assert_equal 0, repository.watchers
    assert_equal 0, repository.forks
    assert_equal 'prasadsurase', repository.owner
    assert_equal 'https://github.com/prasadsurase/code-curiosity', repository.source_url
    assert_equal 67219068, repository.gh_id
    assert_equal 'git@github.com:prasadsurase/code-curiosity.git', repository.ssh_url
    assert_includes repository.languages, 'Ruby'
  end

end
