require "test_helper"
require "sidekiq/testing"

class HackathonTest < ActiveSupport::TestCase

  def setup
    Sidekiq::Testing.fake!
    @hackathon = create(:hackathon, user: create(:user))
    @hackathon_r = create(:hackathon_with_repositories, user: create(:user))

    simulate_contributions
  end

  # Returns the new hackathon object for the new member
  def add_member_to_hackathon(hackathon = @hackathon_r, new_user = nil)
    hackathon.update_attribute(:status, "open")
    new_user = create(:user) unless new_user

    # Post addtion of a member to the hackathon group,
    # a hackathon object should be created for that user!
    hackathon.group.members << new_user

    # returns the new hackathon object for that user
    new_user.subscriptions.where(round: hackathon.round).first
  end

  def simulate_contributions(user = @hackathon_r.user,
			     round = @hackathon_r.round,
			     repository = @hackathon_r.repositories.first)
    # Simulate commits and activities for the user on some random repository
    create_list(:commit, 2, repository: repository, auto_score: 2, user: user, round: round)
    create_list(:activity, 2, repository: repository, auto_score: 1, user: user, round: round)
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
    assert_not_empty @hackathon.round.name
    assert_not_empty @hackathon.group.name
    assert_equal @hackathon.round.name, @hackathon.group.name
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
    @hackathon.round.update_attribute(:status, "open")
    @hackathon.update_attribute(:update_interval, 5)
    assert @hackathon.valid? == false
    assert_not_empty @hackathon.errors[:update_interval]
    assert_equal 15, @hackathon.update_interval
  end

  test "update_interval_cannot_be_updated_if_hackathon_round_is_closed" do
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

  test "points_is_not_calculated_when_the_hackathon_round_is_inactive" do
    # default state of the hackathon is "inactive"
    @hackathon_r.update_points 
    assert_equal 0, @hackathon_r.points 
  end

  test "points_updation_does_not_create_any_transactions" do
    @hackathon_r.update_attribute(:status, "open")
    @hackathon_r.update_points 
    assert_equal 6, @hackathon_r.points 

    assert_empty @hackathon_r.transactions
  end

  test "points_is_updated_for_commits_and_activity_only_for_hackathon_repositories" do
    dummy = create(:repository_with_activity_and_commits)
    @hackathon_r.update_attribute(:status, "open")
    @hackathon_r.update_points 
    assert_equal 6, @hackathon_r.points 
  end

  test "points_for_user_are_updated_for_commits_and_activity_only_for_hackathon_repositories" do
    @hackathon_r.update_attribute(:status, "open")
    simulate_contributions(@hackathon_r.user, create(:round), create(:repository))
    @hackathon_r.update_points 
    assert_equal 6, @hackathon_r.points 
  end

  test "points_is_updated_for_all_commits_and_activity_if_hackathon_repositories_is_blank" do
    simulate_contributions(@hackathon.user, @hackathon.round, create(:repository))
    assert_empty @hackathon.repositories

    @hackathon.update_attribute(:status, "open")
    @hackathon.update_points
    assert_equal 6, @hackathon.points 
  end

  test "points_is_updated_only_for_commits_and_activity_between_start_and_end_of_hackathon_round" do
    ## Test with @hackathon with empty repositories
    @hackathon.update_attribute(:status, "open")

    # check for sanity - currenly open hackathon
    simulate_contributions(@hackathon.user, @hackathon.round, create(:repository))
    @hackathon.update_points 
    assert_equal 6, @hackathon.points 

    @hackathon.update_attribute(:status, "close")
    # make more contributions after hackathon has closed
    simulate_contributions(@hackathon.user, @hackathon.round, create(:repository))

    # new contribs should not have impacted hackathon score!
    @hackathon.update_points 
    assert_equal 6, @hackathon.points 

    ### Test with @hackathon_r i.e. with repositories.
    @hackathon_r.update_attribute(:status, "open")

    # check for sanity - currenly open hackathon
    @hackathon_r.update_points 
    assert_equal 6, @hackathon_r.points 

    @hackathon_r.update_attribute(:status, "close")
    # make more contributions to hackathon repos
    simulate_contributions

    # new contribs should not have impacted hackathon score!
    @hackathon_r.update_points 
    assert_equal 6, @hackathon_r.points 
  end

  test "sidekiq_job_should_be_enqueued_for_next_fetch_data_after_udpate_interval" do
  end

  test "new_member_can_be_added_to_hackathon_group_if_hackathon_round_is_open" do
    @hackathon_r.update_attribute(:status, "open")
    assert_empty @hackathon_r.group.members
    assert_equal @hackathon_r.group.owner, @hackathon_r.user

    # Add 2 members to the hackathon that is open.
    @hackathon_r.group.members << create(:user)
    @hackathon_r.group.members << create(:user)
    assert_equal 2, @hackathon_r.group.members

    # Now we close the hackathon -- no more members should be able to join.
    @hackathon_r.update_attribute(:status, "close")
    @hackathon_r.group.members << create(:user)
    assert_equal 2, @hackathon_r.group.members
  end

  test "new_member_should_have_a_valid_hackathon_round_and_group" do
    nh = add_member_to_hackathon 

    flunk "not yet completed"

    assert nh.valid?
    assert_equal nh.group, @hackathon_r.group
    assert_equal nh.round, @hackathon_r.round
    assert_equal nh.repositories, @hackathon_r.repositories
    assert_equal nh.name, @hackathon_r.name
  end

  test "new_member_points_is_calculated_from_round_start_datetime_if_hackathon_round_is_open" do
    nu = create(:user)

    # create commits worth 4 points in the same repository as that of the hackthon but 1 day prior
    create_list(:commit, 2, repository: @hackathon_r.repositories.first, 
			    auto_score: 2, user: nu, round: @hackathon_r.round,
	                    commit_date: @hackathon_r.round.from_date - 1.day)

    nh = add_member_to_hackathon(@hackathon_r, nu)

    flunk "not yet completed"

    # Create contribs worth 12 points.
    simulate_contributions(nh.user, nh.round, nh.repositories.first)
    simulate_contributions(nh.user, nh.round, nh.repositories.first)

    nh.update_points
    assert_equal 12, nh.points
  end

  test "widget_shows_only_points_of_members_of_the_hackathon" do
  end

  test "widget_shows_points_of_members_with_non_zero_points_only_for_the_hackathon_round" do
  end

  test "widget_shows_points_of_members_if_hackathon_round_is_closed" do
    # use travel_to to test what happens after the hackathon has closed.
    # travel_to @hackthon.round.end_date + 1.day do 
  end

  # not sure if we need to check this.
  test "hackathon_round_score_is_different_from_user_monthly_subscription_round" do
  end

  test "hackathon_round_score_is_a_subset_of_user_monthly_subscription_round" do
  end

end
