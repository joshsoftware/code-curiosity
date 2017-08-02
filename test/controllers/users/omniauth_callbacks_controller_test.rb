require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  test "github signup" do

    OmniAuth.config.test_mode = true
    date = Date.new(2015, 10, 10)
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
          :login => 'hello',
          :created_at => date
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
    assert_equal date, @user.github_user_since
    assert_response :redirect
  end

  test "sponsorer github signup" do
    OmniAuth.config.test_mode = true
    date = Date.new(2015, 10, 10)
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
          :login => 'hello',
          :created_at => date
        }
      },
      :credentials => {
        :token => 'github_omiauth_test'
      },
      :user_params => {
        :user => 'Sponsorer'
      }
    }

    OmniAuth.config.add_mock(:github, omniauth_hash)

    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    request.env['omniauth.params'] = OmniAuth.config.mock_auth[:github][:user_params]

    round = create(:round, status: 'open')

    get :github

    @user = assigns(:user)

    assert @user.valid?
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "existing user sign in as sponsorer" do
    # round = create(:round, :status => 'open')
    # @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    # @user.last_sign_in_at = Time.zone.now
  end

  test "second time login of sponsorer" do

  end

end

