require 'test_helper'

class CommitJobTest < ActiveJob::TestCase
  def setup
    super
    @user = create :user, github_handle: 'prasadsurase', auth_token: 'sometoken'
    @round = create :round, :open
    @repo = create :repository, name: 'code-curiosity', owner: @user.github_handle
    @user.repositories << @repo
    @user.save
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
    assert_equal 1, @user.repositories.count
    assert_equal 1, Repository.count
  end

  test 'perform' do
    CommitJob.perform_later(@user.id.to_s)
    assert_enqueued_jobs 1
    CommitJob.perform_later(@user.id.to_s, 'all')
    assert_enqueued_jobs 2
    CommitJob.perform_later(@user.id.to_s, 'all', @repo.id.to_s, @round.id.to_s)
    assert_enqueued_jobs 3
  end

  test 'perform with Github::Error::UnavailableForLegalReasons exception' do
    CommitsFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::UnavailableForLegalReasons, {})
    CommitJob.perform_now(@user.id.to_s, 'all', @repo.id.to_s, @round.id.to_s)
    @user.reload
    refute_nil @user.auth_token
    assert_equal 0, @user.repositories.count
    assert_equal 0, Repository.count
  end

  test 'perform with Github::Error::NotFound exception' do
    CommitsFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::NotFound, {})
    CommitJob.perform_now(@user.id.to_s, 'all', @repo.id.to_s, @round.id.to_s)
    @user.reload
    refute_nil @user.auth_token
    assert_equal 0, @user.repositories.count
    assert_equal 0, Repository.count
  end

  test 'perform with Github::Error::Unauthorized exception' do
    skip 'Need to figure out how to test infinite retries'
    CommitsFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::Unauthorized, {})
    User.any_instance.stubs(:refresh_gh_client).returns(true)
    CommitJob.perform_now(@user.id.to_s, 'all', @repo.id.to_s, @round.id.to_s)
    @user.reload
    assert_nil @user.auth_token
  end

  test 'perform with Github::Error::Forbidden exception' do
    skip 'Need to figure out how to test infinite retries'
    CommitsFetcher.any_instance.stubs(:fetch).with(:all).raises(Github::Error::Forbidden, {})
    User.any_instance.stubs(:refresh_gh_client).returns(true)
    CommitJob.perform_now(@user.id.to_s, 'all', @repo.id.to_s, @round.id.to_s)
    @user.reload
    refute_nil @user.auth_token
  end

end
