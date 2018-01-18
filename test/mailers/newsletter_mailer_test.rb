require "test_helper"

class NewsletterMailerTest < ActionMailer::TestCase
  include ActiveJob::TestHelper

  test "when delivered it creates an enqueued job" do
    user = create :user
    subject = "General newsletter"
    template = "general.html.haml"
    clear_enqueued_jobs
    clear_performed_jobs
    assert_enqueued_jobs 0
    NewsletterMailer.general(subject, template, user.id.to_s).deliver_later
    assert_enqueued_jobs 1
  end
end
