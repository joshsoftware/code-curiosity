require "test_helper"

class TransactionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "must get user transactions" do
    user = create :user 
    sign_in user
    xhr :get, :index, format: :js,  :id => user.id
    assert_response :success
    assert_not_empty assigns(:transactions) 
  end
end
