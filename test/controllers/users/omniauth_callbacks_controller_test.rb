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
    assert_not_nil @user.uid
    assert_response :redirect
  end

  test 're-signup' do
    OmniAuth.config.test_mode = true

    omniauth_hash = {
      provider: 'github',
      uid: '12345',
      info: {
        name: 'test user',
        email: 'test@test.com'
      },
      extra: {
        raw_info: { login: 'hello' }
      },
      credentials: { token: 'github_omiauth_test' }
    }

    OmniAuth.config.add_mock(:github, omniauth_hash)

    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    round = create(:round, status: 'open')

    get :github
    assert_equal User.count, 1

    @user = assigns(:user)

    sign_out @user
    # update user to be set as deleted
    @user.update({deleted_at: Time.now, auto_created: true, active: false})

    get :github
    @user = assigns(:user)
    assert_equal User.count, 1
  end

end

