require "test_helper"

class JudgingControllerTest < ActionController::TestCase

  let(:org) { 'joshsoftware' }
  let(:request_path) { "/orgs/#{org}" }
  let(:body) { File.read('test/fixtures/org.json') }
  let(:status) { 200 }

  def get_stub
    stub_get(request_path).to_return(body: body, status: status,
      headers: {content_type: "application/json; charset=utf-8"})
  end

  def setup
    super
    get_stub
    @goal = create :goal
    @round = create :round, :open
    @user = create :user, auth_token: Faker::Lorem.word, goal: @goal, is_judge: true
    @org = create :organization
    @org.users << @user
    @repo = create :repository_with_activity_and_commits, organization: @org
  end

  test 'commits' do
    round = create :round, :closed, from_date: @round.from_date - 10.days, end_date: @round.from_date - 1.day
    old_commit = create :commit, commit_date: @round.from_date - 1.day
    sign_in @user
    get :commits
    assert_response :success
    assert_template :commits

    commits = assigns(:commits)
    assert commits.count, 1
    assert_not commits.include? old_commit
  end

  test 'activities' do
    round = create :round, :closed, from_date: @round.from_date - 10.days, end_date: @round.from_date - 1.day
    old_activity = create :activity, commented_on: @round.from_date - 1.day
    sign_in @user
    get :activities
    assert_response :success
    assert_template :activities

    activities = assigns(:activities)
    assert activities.count, 1
    assert_not activities.include? old_activity
  end

  test 'comments' do
    commit = @repo.commits.first
    comment = create :comment, is_public: true, commentable: commit, user: @user
    sign_in @user
    xhr :get, :comments, type: 'commits', resource_id: commit.id
    assert_response :success
    assert_template :comments
    assert assigns(:comments).include? comment
  end

  test 'comment' do
    activity = @repo.activities.first
    sign_in @user
    xhr :post, :comment, type: 'activity', resource_id: activity.id, comment: { content: 'some comment', is_public: true }
    assert_response :success
  end

  test 'rate' do
    skip 'Needs test case'
  end
end
