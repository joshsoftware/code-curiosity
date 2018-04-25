require "test_helper"

class StripeControllerTest < ActionController::TestCase
  test "should update the subscription details when subscription is created" do
    skip("test case yet to be completed")
  end

  test "should update subscription expiry date with new billing period end on payment success" do
    skip("test case yet to be completed")
  end

  test "should notify sponsor if payment fails for first attempt" do
    skip("test case yet to be completed")
  end

  test "should deliver mail with proper content on payment failure" do
    skip("test case yet to be completed")
  end

  # if payment fails for 3 attempts subscription shuld go in unpaid state
  test "should update subscription status when subscription updated event occurs" do
    skip("test case yet to be completed")
  end

  test "should reactivate the subscription when sponsor updates credit card details" do
    skip("test case yet to be completed")
  end
end
