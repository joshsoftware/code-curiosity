require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  def setup
    super
    @round_1 = create :round, :open
  end

  test "score should be 0 if total no of words are less than 25" do
    activity = create(:activity, :comment, description: Faker::Lorem.words, user: create(:user), event_action: 'created')
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 0
  end

  test "score should be 1 if no of words are greater than 25 but less than 40" do
    activity = create(:activity, :comment, description: Faker::Lorem.words(30, true).join(' '), user: create(:user), event_action: 'created')
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 1
  end

  test "score should be 2 if no of words greater than 40" do
    activity = create(:activity, :issue, description: Faker::Lorem.words(45, true).join(' '), user: create(:user), event_action: 'opened')
    assert_equal activity.auto_score, nil
    activity.calculate_score_and_set
    assert_equal activity.auto_score, 2
  end

  test "activity max rating should be 2" do
    activity = create(:activity, :comment, description: Faker::Lorem.words, user: create(:user), event_action: 'created')
    max_rating = 2
    assert_equal activity.max_rating, max_rating
  end

  test "comments with same description for a repo and an user should exists atleast 1 hour apart" do
    description = Faker::Lorem.words
    user = create :user
    commented_on = DateTime.now - 1.hour
    activity = create(:activity, :comment, description: description, user: user, event_action: :created, repo: 'owner/repo',
                      commented_on: commented_on)
    assert activity.valid?
    activity2 = build(:activity, :comment, description: description, user: user, event_action: :created, repo: 'owner/repo',
                      commented_on: commented_on + 60.minutes)
    refute activity2.valid?
    assert_equal 1, activity2.errors.count
    assert_equal activity2.errors.messages[:description], ['Duplicate comment for the same repository by the same user']
    activity2 = build(:activity, :comment, description: Faker::Lorem.words, user: user, event_action: :created, repo: 'owner/repo',
                      commented_on: commented_on + 60.minutes)
    assert activity2.valid?
    activity2 = build(:activity, :comment, description: description, user: user, event_action: :created, repo: 'owner/other-repo',
                      commented_on: commented_on + 60.minutes)
    assert activity2.valid?
    activity2 = build(:activity, :comment, description: description, user: user, event_action: :created, repo: 'owner/repo',
                      commented_on: commented_on + 61.minutes)
  end

  test "activities count of user should be zero before any activity is created" do
    activity = build(:activity, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 0
  end

  test "activities count of user should be incremented after activity is created" do
    activity = create(:activity, :issue, description: Faker::Lorem.words)
    assert_equal activity.user.activities_count, 1
  end

  test "consider for scoring scope should not retrive closed event_actions" do
    opened_issue = create(:activity, :issue, description: Faker::Lorem.words, event_action: 'opened')
    closed_issue = create(:activity, :issue, description: Faker::Lorem.words, event_action: 'closed')
    created_comment = create(:activity, :comment, description: Faker::Lorem.words, event_action: 'created')
    deleted_comment = create(:activity, :comment, description: Faker::Lorem.words, event_action: 'deleted')
    edited_comment = create(:activity, :comment, description: Faker::Lorem.words, event_action: 'edited')
    activities = Activity.considered_for_scoring.to_a
    assert_equal activities.count, 2
    assert_includes activities, opened_issue
    assert_includes activities, created_comment
    refute_includes activities, closed_issue
    refute_includes activities, edited_comment
    refute_includes activities, deleted_comment
  end

  test "scoring of only opened and reopened issue should be done" do
    description = "CodeCuriosity is a platform that encourages contributions to open source. Everyone is rewarded for their efforts, no matter how big or small they are. This is not a winner takes all competition"
    closed_issue = create(:activity, :issue, description: description, event_action: 'closed')
    opened_issue = create(:activity, :issue, description: description, event_action: 'opened')
    reopened_issue = create(:activity, :issue, description: description, event_action: 'reopened')
    assert_equal 3, Activity.count

    closed_issue.calculate_score_and_set
    opened_issue.calculate_score_and_set
    reopened_issue.calculate_score_and_set

    assert_equal closed_issue.auto_score, 0
    assert_equal opened_issue.auto_score, 1
    assert_equal reopened_issue.auto_score, 1
  end

  test "scoring of only created comment should be done" do
    description = "CodeCuriosity is a platform that encourages contributions to open source. Everyone is rewarded for their efforts, no matter how big or small they are. This is not a winner takes all competition"
    created_comment = create(:activity, :comment, description: description, event_action: 'created')
    edited_comment = create(:activity, :comment, description: description, event_action: 'edited')
    created_comment.calculate_score_and_set
    edited_comment.calculate_score_and_set

    assert_equal created_comment.auto_score, 1
    assert_equal edited_comment.auto_score, 0
  end

  test "round should be present" do
    activity = create(:activity, :issue, description: Faker::Lorem.words)
    assert activity.round.present?
  end

  test "proper round is assigned" do
    skip "this feature needs to be added"
    round_1 = create :round, from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    round_2 = create :round, from_date: Date.today.beginning_of_month - 1.month, end_date: Date.today.end_of_month - 1.month
    activity_1 = create :activity, description: Faker::Lorem.words, commented_on: Date.today, round: nil
    assert_equal activity_1.round, round_1
    activity_2 = create :activity, description: Faker::Lorem.words, commented_on: Date.today - 1.month, round: nil
    assert_equal activity_2.round, round_2
  end
end
