require "test_helper"

class SubscriptionsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  test "subscription test for new user" do
    assert_difference 'Subscription.count',1 do   
      round = create :round
      user = create :user 
      user.points =  WALLET_CONFIG['subscription_amount'] 
      sign_in user
      get :subscribe, :id =>  user.id
      assert_redirected_to users_path
    end
  end

  test "subscription test for already subscribed user" do
    round = create :round
    user = create :user 
    user.subscriptions.create(round: round)
    sign_in user
    get :subscribe, :id => user.id
    assert_redirected_to root_path
  end

  test "unauthorized user not allowed" do
    user = create :user 
    get :subscribe, :id => user.id
    assert_redirected_to new_user_session_path
  end

  test "require sufficient balance for subscription" do
    user = create :user
    user.points =  0
    user.save
    sign_in user
    get :subscribe, :id => user.id
    assert_redirected_to root_path
  end
  

end
