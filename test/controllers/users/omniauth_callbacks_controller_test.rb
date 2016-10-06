require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase

  include Devise::TestHelpers  

  test "github signup" do
    
    OmniAuth.config.test_mode = true

    omniauth_hash = {
      :provider => 'github',
      :uid => '12345',
      :info => {
        :name => 'test user',
        :email => 'test@test.com'
      },
      :extra => {
        :raw_info => 
        {
          :login => 'hello'
        }
      },
      :credentials => {
        :token => 'github_omiauth_test'
      }
    }

    OmniAuth.config.add_mock(:github, omniauth_hash)

    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github] 
    round = create(:round, status: 'open')
   
    get :github

    @user = assigns(:user)

    assert @user.valid? 
    assert @user.persisted?
    assert_not_nil @user.name
    assert_not_nil @user.email
    assert_not_nil @user.github_handle
    assert_response :redirect
  end

end

