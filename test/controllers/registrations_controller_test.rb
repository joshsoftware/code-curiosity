require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :auth_token => 'dah123rty')
    sign_in @user
  end

  test 'if user has not accepted terms and conditions' do
    get :terms_and_conditions

    assert_template 'terms_and_conditions'
  end

  test 'if user has accepted terms and conditions' do
    get :terms_and_conditions, terms_and_conditions: true

    assert_redirected_to dashboard_path
  end
end
