require "test_helper"
require "sidekiq/testing"

class HackathonTest < ActiveSupport::TestCase

  def setup
    Sidekiq::Testing.fake!
    @hackathon = create(:hackathon, user: create(:user))
  end

  test "is_valid" do
     assert(@hackathon.valid?)
     assert(@hackathon.round.valid?)
     assert(@hackathon.group.valid?)
  end

  test "does_not_create_any_goal" do
  end

  test "has_valid_hackathon_group" do
  end

  test "is_valid_if_there_is_only_group_admin_and_no_members_in_the_hackathon_group" do
  end

  test "has_valid_hackathon_round" do
  end

  test "hackathon_round_has_initial_state_as_inactive" do
  end

  test "sidekiq_job_should_be_enqueued_to_open_hackathon_round_at_start_datetime" do
  end

  test "update_interval_can_be_updated_if_hackathon_round_is_inactive" do
  end

  test "update_interval_cannot_be_updated_if_hackathon_round_is_open" do
  end

  test "update_interval_cannot_be_updated_if_hackathon_round_is_closed" do
  end

  test "is_valid_if_repositories_array_is_blank" do
  end

  test "is_valid_if_repositories_array_has_valid_repository_ids" do
  end

  test "repositories_should_not_reference_hackathon" do#check inverse_of: nil
  end

  # Need to add test cases to add repositories.
  test "points_is_updated_if_round_spans_different_months" do  # eg. Hackathon is from 30-Mar till 2-Apr
  end

  test "points_is_updated_for_commits_and_activity_only_for_hackathon_repositories" do
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
