require "test_helper"

class Admin::RepositoriesControllerTest < ActionController::TestCase 
 
  test "must update repository's ignore field" do
    seed_data
    assert_equal false, @repo.ignore 
    xhr :patch, :update_ignore_field, { ignore_value: true, id: @repo.id }, format: :js
    assert_response :success
    assert_equal true, @repo.reload.ignore 
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    @user.roles << role
    sign_in @user
    @repo = create(:repository)
  end
end  
