require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase

  def test_commits_count_will_be_zero_if_no_commit_exist
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    assert_equal subscription.commits_count, 0
  end

  def test_commits_count_should_not_be_zero_after_creating_commit
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    commit = create(:commit, user: user, round: round)
    assert_not_nil subscription.commits_count
  end

  def test_activities_count_will_be_zero_if_no_activity_exist
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    assert_equal subscription.activities_count, 0
  end

  def test_activities_count_should_not_be_zero_after_creating_activities
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    activity = create(:activity, user: user, round: round)
    assert_not_nil subscription.activities_count
  end

  def test_commits_score
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    commit = create_list(:commit, 2, :auto_score => 2, :commit_date => Faker::Time.between(DateTime.now - 1, DateTime.now), user: user, round: round)
    assert_equal subscription.commits_score, 4
  end

  def test_total_activities_score
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    activity = create_list(:activity, 3, :auto_score => 1, user:user, round: round)
    create(:activity, event_action: :closed, user: user, round: round, auto_score: 1)
    assert_equal subscription.activities_score, 0
  end

  def test_total_activities_score_when_event_type_is_comment_and_event_action_is_created
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, user: user, round: round)
    create(:activity, event_type: :comment, event_action: :created, user: user, round: round, auto_score: 2)
    assert_equal subscription.activities_score, 2
  end

  def test_update_total_points
    user = create(:user)
    round = create(:round)
    subscription = create(:subscription, :points => 0, user: user, round: round)
    commit = create_list(:commit, 2, :auto_score => 2, user: user, round: round)
    activity = create_list(:activity, 3, :auto_score => 1, user:user, round: round)
    subscription.update_points
    total_points = subscription.commits_score + subscription.activities_score
    assert_equal subscription.points, total_points
  end

  def test_no_credit_when_point_is_0
    subscription = build(:subscription, :points => 0)
    assert_not subscription.credit_points
  end

  def test_when_points_is_greater_than_zero_credit_transaction
    subscription = build(:subscription, :points => 2)
    subscription.credit_points
    assert_not_nil subscription.transactions
  end


  def test_create_credit_transaction_only_when_transaction_type_is_credit
    subscription = create(:subscription)
    subscription.create_credit_transaction('credited', 2)
    assert_not_nil subscription.transactions.count
  end

  def test_goal_not_achieved_when_total_points_is_less_than_goal_points
    subscription = build(:subscription, :points => 0)
    subscription.goal.points = 1
    assert_not subscription.goal_achived?
  end

  def test_goal_achieved_only_when_points_must_be_greater_than_or_equal_to_goal_points
    subscription = build(:subscription, :points => 1, user: FactoryGirl.create(:user))
    subscription.goal.points = 1
    assert subscription.goal_achived?
  end

  def test_credit_transaction_GoalBonus_when_points_greater_than_goal_points
    goal = build(:goal, :points => 15, :bonus_points => 20)
    subscription = build(:subscription, :points => 20, goal: goal)
    subscription.credit_points
    transaction_type = subscription.transactions.last.transaction_type
    assert_equal transaction_type, 'GoalBonus'
  end

end
