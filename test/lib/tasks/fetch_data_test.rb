require 'test_helper'

class FetchDataTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    clear_enqueued_jobs
    clear_performed_jobs
    CodeCuriosity::Application.load_tasks
  end

  def teardown
    super
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test 'must not fetch commits and activities if user is blocked and is contestant' do
    # contestant and blocked
    user = create :user, blocked: true, auto_created: false
    round = create :round, :open
    repository = create :repository
    user.repositories << repository
    commit = create :commit, round: round, user: user, repository: repository
    activity = create :activity, round: round, user: user, repository: repository
    clear_enqueued_jobs
    clear_performed_jobs
    Rake::Task['fetch_data:commits_and_activities'].reenable
    Rake::Task['fetch_data:commits_and_activities'].invoke
    assert_enqueued_jobs 0
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test 'must not fetch repositories if user is blocked and is contestant' do
    # contestant and blocked
    user = create :user, blocked: true, auto_created: false
    round = create :round, :open
    repository = create :repository
    user.repositories << repository
    commit = create :commit, round: round, user: user, repository: repository
    activity = create :activity, round: round, user: user, repository: repository
    clear_enqueued_jobs
    clear_performed_jobs
    Rake::Task['fetch_data:sync_repos'].reenable
    Rake::Task['fetch_data:sync_repos'].invoke
    assert_enqueued_jobs 0
  end
end
