require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase

  test "subscription must create a transaction" do
      user = FactoryGirl.create :user
      user.subscriptions.create 
      transaction_type = Transaction.order_by(:created_at => :desc).first.transaction_type
      assert_equal transaction_type,"debited"
  end


end
