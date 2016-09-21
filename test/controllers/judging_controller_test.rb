require "test_helper"

class JudgingControllerTest < ActionController::TestCase

  test 'commits' do
    goal = create :goal
    round = create :round, name: 'first', from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month, status: :open
    user = create :user, auth_token: 'dah123rty', goal: goal, is_judge: true
    org = Organization.setup('dolores', user)
    repo = create :repository_with_activity_and_commits, organization: org
    old_commit = create :commit, commit_date: round.from_date - 1.day
    sign_in user
    get :commits
    assert_response :success
    assert_template :commits

    commits = assigns(:commits)
    assert commits.count, 1
    assert_not commits.include? old_commit
  end

  test 'activities' do
    goal = create :goal
    round = create :round, name: 'first', from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month, status: :open
    user = create :user, auth_token: 'dah123rty', goal: goal, is_judge: true
    org = Organization.setup('dolores', user)
    repo = create :repository_with_activity_and_commits, organization: org
    old_activity = create :activity, commented_on: round.from_date - 1.day
    sign_in user
    get :activities
    assert_response :success
    assert_template :activities

    activities = assigns(:activities)
    assert activities.count, 1
    assert_not activities.include? old_activity
  end

  test 'comments' do
    goal = create :goal
    round = create :round, name: 'first', from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month, status: :open
    user = create :user, auth_token: 'dah123rty', goal: goal, is_judge: true
    org = Organization.setup('dolores', user)
    repo = create :repository_with_activity_and_commits, organization: org
    commit = repo.commits.first
    comment = create :comment, is_public: true, commentable: commit, user: user
    sign_in user
    xhr :get, :comments, type: 'commits', resource_id: commit.id
    assert_response :success
    assert_template :comments
    assert assigns(:comments).include? comment
  end

  test 'comment' do
    goal = create :goal
    round = create :round, name: 'first', from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month, status: :open
    user = create :user, auth_token: 'dah123rty', goal: goal, is_judge: true
    org = Organization.setup('dolores', user)
    repo = create :repository_with_activity_and_commits, organization: org
    activity = repo.activities.first
    sign_in user
    xhr :post, :comment, type: 'activity', resource_id: activity.id, comment: { content: 'some comment', is_public: true }
    assert_response :success
  end

  test 'rate' do
    skip 'Needs test case'
  end

end
