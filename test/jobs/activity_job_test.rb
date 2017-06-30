require 'test_helper'

class ActivityJobTest < ActiveJob::TestCase
  def setup
    super
    @user = create :user, github_handle: 'prasadsurase', auth_token: 'sometoken'
    @round = create :round, :open
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
  end

  test 'perform' do
    ActivityJob.perform_later(@user.id.to_s)
    assert_enqueued_jobs 1
    ActivityJob.perform_later(@user.id.to_s, 'all')
    assert_enqueued_jobs 2
    ActivityJob.perform_later(@user.id.to_s, 'all', @round.id.to_s)
    assert_enqueued_jobs 3
  end

  test 'perform with Github::Error::NotFound exception' do
    ActivitiesFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::NotFound, {})
    ActivityJob.perform_now(@user.id.to_s, 'all', @round.id.to_s)
    @user.reload
    refute_nil @user.auth_token
  end

  test 'perform with Github::Error::Unauthorized exception' do
    skip 'Need to figure out how to test infinite retries'
    User.any_instance.stubs(:refresh_gh_client).returns(false)
    ActivitiesFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::Unauthorized, {})
    ActivityJob.perform_now(@user.id.to_s, 'all', @round.id.to_s)
    @user.reload
    assert_nil @user.auth_token
  end

  test 'perform with Github::Error::Forbidden exception' do
    skip 'Need to figure out how to test infinite retries'
    User.any_instance.stubs(:refresh_gh_client).returns(false)
    ActivitiesFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::Forbidden, {})
    ActivityJob.perform_now(@user.id.to_s, 'all', @round.id.to_s)
    @user.reload
    refute_nil @user.auth_token
  end

end
