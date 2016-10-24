require "test_helper"
require "sidekiq/testing"

class HackathonTest < ActiveSupport::TestCase

  def setup
    Sidekiq::Testing.fake!
    @hackathon = create(:hackathon, user: create(:user))
    @hackathon_r = create(:hackathon_with_repositories, user: create(:user))

    # Simulate commits and activities for this user (total user points should be: 6)
    create_list(:commit, 2, repository: @hackathon_r.repositories.first,
			    auto_score: 2, user: @hackathon_r.user, round: @hackathon_r.round)
    create_list(:activity, 2, :issue, repository: @hackathon_r.repositories.last,
			    auto_score: 1, user: @hackathon_r.user, round: @hackathon_r.round)
  end

  test "is_valid" do
    assert @hackathon.valid?
    assert @hackathon.group.valid?
    assert @hackathon.round.valid?
    assert_equal @hackathon.round.status, "inactive"
    assert_empty @hackathon.repositories
    assert_not_empty @hackathon_r.repositories
  end

  test "round_name_and_group_name_should_be_the_same" do
    skip 'pending'
    assert_not_empty @hackathon.round.name
    assert_not_empty @hackathon.group.name
  end

  test "does_not_create_any_goal" do
    assert_nil @hackathon.goal
    assert_nil @hackathon_r.goal
  end

  test "sidekiq_job_should_be_enqueued_to_open_hackathon_round_at_start_datetime" do
  end

  test "update_interval_can_be_updated_if_hackathon_round_is_inactive" do
    @hackathon.update_attribute(:update_interval, 5)
    assert @hackathon.valid?
    assert_equal 5, @hackathon.update_interval
  end

  test "update_interval_cannot_be_updated_if_hackathon_round_is_open" do
    skip 'pending'
    @hackathon.round.update_attribute(:status, "open")
    @hackathon.update_attribute(:update_interval, 5)
    assert @hackathon.valid? == false
    assert_not_empty @hackathon.errors[:update_interval]
    assert_equal 15, @hackathon.update_interval
  end

  test "update_interval_cannot_be_updated_if_hackathon_round_is_closed" do
    skip 'pending'
    @hackathon.round.update_attribute(:status, "close")
    @hackathon.update_attribute(:update_interval, 5)
    assert @hackathon.valid? == false
    assert_not_empty @hackathon.errors[:update_interval]
    assert_equal 15, @hackathon.update_interval
  end

  test "repositories_should_not_reference_hackathon" do #check inverse_of: nil
    @hackathon_r.repositories.each do |r|
      assert_equal false, r.has_attribute?(:hackathon_ids)
    end
    assert_raises(NoMethodError) { @hackathon_r.repositories.first.hackathons.first }
  end

  test "repositories_can_be_added_to_hackathon_if_status_is_open" do
    @hackathon_r.round.update_attribute(:status, "open")
    @hackathon_r.repositories << create(:repository)
    assert_equal 4, @hackathon_r.repositories.count
  end

  test "points_is_updated_if_round_spans_different_months" do  # eg. Hackathon is from 30-Mar till 2-Apr
  end

  test "points_is_updated_for_commits_and_activity_only_for_hackathon_repositories" do
    skip 'pending'
    dummy = create(:repository_with_activity_and_commits)
    @hackathon_r.update_points
    assert_equal 6, @hackathon_r.points
  end

  test "points_is_updated_for_all_commits_and_activity_if_hackathon_repositories_is_blank" do
  end

  test "points_is_updated_only_for_commits_and_activity_between_start_and_end_of_hackathon_round" do
  end

  test "points_is_not_calculated_when_the_hackathon_round_is_inactive" do
  end

  test "points_updation_does_not_create_any_transactions" do
  end

  test "sidekiq_job_should_be_enqueued_for_next_fetch_data_after_udpate_interval" do
  end

  test "new_member_can_be_added_to_hackathon_group_if_hackathon_round_is_open" do
  end

  test "new_member_points_is_calculated_from_round_start_datetime_if_hackathon_round_is_open" do
  end

  test "existing_member_points_is_updated_from_last_interval_time_if_hackathon_round_is_open" do
  end

  test "widget_shows_points_of_members_with_non_zero_points_only_for_the_hackathon_round" do
  end

  test "widget_shows_points_of_members_if_hackathon_round_is_closed" do
  end

  # not sure if we need to check this.
  test "hackathon_round_score_is_different_from_user_monthly_subscription_round" do
  end

  test "hackathon_round_score_is_a_subset_of_user_monthly_subscription_round" do
  end

end
