require "test_helper"

class Admin::IgnoredFilesControllerTest < ActionController::TestCase

  def setup
    super
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty')
    @user.roles << role
    sign_in @user
  end

  test "should get ignored_files list" do
    ignored_file = create :file_to_be_ignored, name: 'Gemfile.lock', programming_language: 'ruby'
    xhr :get, :index, format: :js
    assert_response :success
    assert_template 'ignored_files/index'
    assert_template 'ignored_files/_ignored_file'
  end

  test "on scored-button toggle should render all files that are scored" do
    scored_files = create_list(:file_to_be_ignored, 3)
    ignored_files = create_list(:file_to_be_ignored, 2, ignored: true)
    xhr :get, :index, format: :js
    assert_response :success
    assert_not_nil assigns(:status)
    assert_equal scored_files.count, 3
    assert_equal ignored_files.count, 2
  end

  test "should not update a ignored_file without any parameter" do
    ignored_file = create :file_to_be_ignored
    assert_raises ActionController::ParameterMissing do
      put :update, :id => ignored_file.id
    end
  end

  test "should update ignored_file when either name or ignored field is changed" do
    ignored_file = create :file_to_be_ignored, name: 'Gemfile.lock', programming_language: 'ruby'
    updated_name = 'Gemfile'
    assert_not ignored_file.ignored

    patch :update, :id => ignored_file.id, file_to_be_ignored: {name: updated_name, ignored: true}

    assert_equal updated_name, ignored_file.reload.name
    assert ignored_file.ignored
    assert_response :redirect
  end

  test "should destroy ignored_file" do
    ignored_file = create :file_to_be_ignored, name: 'Gemfile.lock', programming_language: 'ruby'
    assert_difference('FileToBeIgnored.count', -1) do
      delete :destroy, id: ignored_file.id
    end
    assert_response :redirect
  end
end
