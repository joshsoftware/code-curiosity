require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  test "score should be 0 if total no of words are less than 25" do
    activity = create(:activity, description: Faker::Lorem.words, user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 0
  end

  test "score should be 1 if no of words are greater than 25 but less than 40" do
    activity = create(:activity, description: Faker::Lorem.words(30, true).join(' '), user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 1
  end

  test "score should be 2 if no of words greater than 40" do
    activity = create(:activity, description: Faker::Lorem.words(45, true).join(' '), user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 2
  end

  test "activity max rating should be 2" do
    activity = create(:activity, description: Faker::Lorem.words, user: create(:user))
    max_rating = 2
    assert_equal activity.max_rating, max_rating
  end

  test "activities count of user should be zero before any activity is created" do
    activity = build(:activity, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 0
  end

  test "activities count of user should be incremented after activity is created" do
    activity = create(:activity, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 1
  end

  test "consider for scoring scope should not retrive closed event_actions" do
    opened_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'opened')
    closed_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'closed')
    assert_equal Activity.considered_for_scoring.count, 1
    assert_equal Activity.considered_for_scoring.first, opened_activity
  end

  test "scoring scope should retrive created comment event_actions" do
    created_comment = create(:activity, description: Faker::Lorem.words, event_type: 'comment', event_action: 'created')
    opened_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'opened')
    closed_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'closed')
    assert_equal Activity.considered_for_scoring.count, 2
  end

  test "scoring scope should not retrive edited or deleted comment event_actions" do
    edited_comment = create(:activity, description: Faker::Lorem.words, event_type: 'comment', event_action: 'edited')
    deleted_comment = create(:activity, description: Faker::Lorem.words, event_type: 'comment', event_action: 'deleted')
    opened_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'opened')
    closed_activity = create(:activity, description: Faker::Lorem.words, event_type: 'issue', event_action: 'closed')
    assert_equal Activity.considered_for_scoring.count, 1
  end

  test "round should be present" do
    activity = create(:activity, description: Faker::Lorem.words)
    assert activity.round.present?
  end

  test "proper round is assigned" do
    round_1 = create :round, from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    round_2 = create :round, from_date: Date.today.beginning_of_month - 1.month, end_date: Date.today.end_of_month - 1.month
    activity_1 = create :activity, description: Faker::Lorem.words, commented_on: Date.today, round: nil
    assert_equal activity_1.round, round_1
    activity_2 = create :activity, description: Faker::Lorem.words, commented_on: Date.today - 1.month, round: nil
    assert_equal activity_2.round, round_2
  end

end
