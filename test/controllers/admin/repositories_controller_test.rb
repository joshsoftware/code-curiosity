require "test_helper"

class Admin::RepositoriesControllerTest < ActionController::TestCase

  def setup
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal) )
    @user.roles << role
    sign_in @user
    @repo = create(:repository, gh_id: 123439, type: 'popular')
  end

  test "must update ignore field of child and parent repository which are associated with each other through popular_repository_id" do
    repository_1 = create :repository, popular_repository_id: @repo.id
    assert_equal false, @repo.ignore
    assert_equal false, repository_1.reload.ignore
    xhr :patch, :update_ignore_field, { ignore_value: true, id: @repo.id }, format: :js
    assert_equal true, @repo.reload.ignore
    assert_equal true, repository_1.reload.ignore
  end

  test "must update ignore field of child and parent repository which are associated with each other through source_gh_id" do
    repository_1 = create :repository, source_gh_id: @repo.gh_id
    assert_equal false, @repo.ignore
    assert_equal false, repository_1.reload.ignore
    xhr :patch, :update_ignore_field, { ignore_value: true, id: @repo.id }, format: :js
    assert_equal true, @repo.reload.ignore
    assert_equal true, repository_1.reload.ignore
  end

  test "must not update any other repositories which are not ignored" do
    repository_1 = create :repository
    assert_equal false, @repo.ignore
    assert_equal false, repository_1.reload.ignore
    xhr :patch, :update_ignore_field, { ignore_value: true, id: @repo.id }, format: :js
    assert_equal true, @repo.reload.ignore
    assert_equal false, repository_1.reload.ignore
  end

  test "must update ignore field of parent and all its child repositories" do
    repository_1 = create :repository, popular_repository_id: @repo.id
    repository_2 = create :repository, source_gh_id: @repo.gh_id
    assert_equal false, @repo.ignore
    assert_equal false, repository_1.reload.ignore
    assert_equal false, repository_2.reload.ignore
    xhr :patch, :update_ignore_field, { ignore_value: true, id: @repo.id }, format: :js
    assert_response :success
    assert_equal true, @repo.reload.ignore
    assert_equal true, repository_1.reload.ignore
    assert_equal true, repository_2.reload.ignore
  end
end
