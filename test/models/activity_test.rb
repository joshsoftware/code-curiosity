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

end
