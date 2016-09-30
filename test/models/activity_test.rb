require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  def test_score_if_total_no_of_words_less_than_25
    activity = create(:activity, description: Faker::Lorem.words, user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 0
  end

  def test_score_should_be_1_if_no_of_words_are_greater_than_25_but_less_than_40
    activity = create(:activity, description: Faker::Lorem.words(30, true).join(' '), user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 1
  end

  def test_score_should_be_2_if_no_of_words_greater_than_40
    activity = create(:activity, description: Faker::Lorem.words(45, true).join(' '), user: create(:user))
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 2
  end

  def test_activity_max_rating_should_be_2
    activity = create(:activity, description: Faker::Lorem.words, user: create(:user))
    max_rating = 2
    assert_equal activity.max_rating, max_rating
  end

  def test_activities_count_of_user_is_zero_before_any_activity_is_created
    activity = build(:activity, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 0
  end

  def test_activities_count_of_user_is_incremented_after_activity_is_created
    activity = create(:activity, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 1
  end

  def test_round_is_present
    activity = create(:activity, description: Faker::Lorem.words)
    assert activity.round.present?
  end

  def test_proper_round_is_assigned
    round_1 = create :round, from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    round_2 = create :round, from_date: Date.today.beginning_of_month - 1.month, end_date: Date.today.end_of_month - 1.month
    activity_1 = create :activity, description: Faker::Lorem.words, commented_on: Date.today, round: nil
    assert_equal activity_1.round, round_1
    activity_2 = create :activity, description: Faker::Lorem.words, commented_on: Date.today - 1.month, round: nil
    assert_equal activity_2.round, round_2
  end

  def consider_for_scoring_scope_should_not_retrive_closed_event_actions
    opened_activity = create(:activity, description: Faker::Lorem.words, event_action: 'opened')
    closed_activity = create(:activity, description: Faker::Lorem.words, event_action: 'closed')
    assert_equal Activity.considered_for_scoring.count, 1
    assert_equal Activity.considered_for_scoring.first, opened_activity
  end

end
