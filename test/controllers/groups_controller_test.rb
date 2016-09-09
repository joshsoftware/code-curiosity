require "test_helper"

class GroupsControllerTest < ActionController::TestCase

  before(:all) do
    round = create(:round, :status => 'open')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
  end

  test "should not render index to not-logged in user" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "render index for logged-in user" do
    sign_in @user
    get :index
    assert_response :success
  end

  test "display all groups if logged-in in user is admin" do
    sign_in_user_and_assign_groups
    other_user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    other_group = create(:group)
    other_group.owner = other_user
    other_user.groups << other_group
    role = create(:role, :name => 'Admin')
    @user.roles << role
    get :index
    assert_equal assigns(:groups).count, 2
    assert assigns(:groups).include?(other_group)
  end

  test "display groups corresponding to the logged-in user" do
    sign_in_user_and_assign_groups
    other_user = create(:user, goal: create(:goal))
    other_group = create(:group)
    other_group.owner = other_user
    other_user.groups << other_group
    get :index
    assert_equal assigns(:groups).count, 1
    assert_not assigns(:groups).include?(other_group)
  end

  test "should create group" do
    sign_in @user
    assert_difference('Group.count') do
      post :create, group: {name: Faker::Lorem.word, description: Faker::Lorem.sentence}
    end
    assert_response :redirect
    assert_redirected_to group_path(Group.first)
  end

  test "each group should have its owner" do
    sign_in @user
    post :create, group: {name: Faker::Lorem.word, description: Faker::Lorem.sentence}
    assert_equal Group.first.owner, @user
  end

  test "group should not be updated by other group's members" do
    sign_in @user
    group = create(:group)
    @user.groups << group
    other_user = create(:user, goal: create(:goal))
    group.owner = other_user
    other_user.groups << group
    patch :update, :id => group.id, group: {name: 'ait'}
    assert_response 401
  end

  test "group should only be updated by group's owner" do
    sign_in_user_and_assign_groups
    other_user = create(:user, goal: create(:goal))
    other_user.groups << @group
    patch :update, :id => @group.id, group: {name: Faker::Lorem.word}
    assert_response :redirect
  end

  test "should not update group without any parameter" do
    sign_in_user_and_assign_groups
    assert_raises ActionController::ParameterMissing do
      put :update, :id => @group.id
    end
  end

  test "should update group when either name, description, featured is changed" do
    sign_in_user_and_assign_groups
    updated_name = 'group_ait'
    patch :update, :id => @group.id, group: {name: updated_name}
    @group.reload
    assert_response :redirect
    assert_equal @group.name, updated_name
  end

  test "group should not be destroyed by other group's members" do
    sign_in @user
    group = create(:group)
    @user.groups << group
    other_user = create(:user, goal: create(:goal))
    group.owner = other_user
    other_user.groups << group
    delete :destroy, :id => group.id
    assert_response 401
  end

  test "should destroy group" do
    sign_in_user_and_assign_groups
    assert_difference('Group.count', -1) do
      delete :destroy, id: @group.id
    end
    assert_response :redirect
    assert_redirected_to groups_path
  end

  test "should feature group only when user is admin" do
    sign_in @user
    group = create(:group, is_featured: true )
    group.owner = @user
    @user.groups << group
    role = create(:role, :name => 'Admin')
    @user.roles << role
    xhr :patch, :feature, id: group.id
    assert_response :success
    assert_template 'groups/feature'
  end

  def sign_in_user_and_assign_groups
    sign_in @user
    @group = create(:group)
    @group.owner = @user
    @user.groups << @group
  end

end
