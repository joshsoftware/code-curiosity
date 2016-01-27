require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  def subscription
    @subscription ||= Subscription.new
  end

  def test_valid
    assert subscription.valid?
  end
end
