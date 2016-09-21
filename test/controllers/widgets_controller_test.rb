require "test_helper"

class WidgetsControllerTest < ActionController::TestCase
  before(:all) do
    @goal = create :goal
    @round = create :round, :open
    @user = create :user, auth_token: 'dah123rty', goal: @goal
    @other_user = create :user, auth_token: 'dsadasda', goal: @goal
    @organization = create :organization
    @repo = create :repository_with_activity_and_commits, organization: @organization
    @group = create :group, owner: @user
    @group.members << @other_user
  end

  test 'show repository' do
    get :repo, id: @repo.id
    assert_response :success
    assert_template :repo
  end

  test 'show group widget' do
    get :group, id: @group.id
    assert_response :success
    assert_template :group
  end

end
