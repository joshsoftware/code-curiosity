require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    CodeCuriosity::Application.load_tasks if Rake::Task.tasks.empty?
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test 'task to count enqueued job' do
    user1 = create :user
    user2 = create :user
    assert_equal 2, User.contestants.count
    clear_enqueued_jobs
    assert_enqueued_jobs 0
    Rake::Task['newsletter:general'].execute
    assert_includes ActiveJob::Base.queue_adapter.enqueued_jobs.map{ |x| x[:job] },
      ActionMailer::DeliveryJob
  end

  test 'Task dont send newsletter to auto created users of code curiosity' do
    user1 = create :user
    user2 = create :user, auto_created: true
    user3 = create :user
    assert_equal 2, User.contestants.count
    clear_enqueued_jobs
    assert_enqueued_jobs 0
    Rake::Task['newsletter:general'].execute
    assert_includes ActiveJob::Base.queue_adapter.enqueued_jobs.map{ |x| x[:job] },
      ActionMailer::DeliveryJob
  end
end
