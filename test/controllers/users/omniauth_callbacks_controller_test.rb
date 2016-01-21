require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase

  test "github signup" do
    OmniAuth.config.add_mock(:github, {:uid => '12345'})
    
    get :github
  end
  # test "the truth" do
  #   assert true
  # end
end

