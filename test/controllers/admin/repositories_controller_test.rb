require "test_helper"

class Admin::RepositoriesControllerTest < ActionController::TestCase

  def setup
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty')
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

  test 'create repo if present and unforked' do
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(
        JSON.parse(File.read('test/fixtures/unforked_repo.json'))[0]
      )
    )
    assert_equal Repository.count, 1
    post :create, repository: {name: 'code-curiosity', user: 'prasadsurase'}
    assert_equal Repository.count, 2
  end

  test 'Show error if repository not found on github' do
    Repository.any_instance.stubs(:info).returns(nil)
    assert_equal Repository.count, 1
    post :create, repository: {name: 'random name', user: 'ranadom user'}
    assert_equal Repository.count, 1
  end

  test 'Show error if repository is forked' do
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(
        JSON.parse(File.read('test/fixtures/repo.json'))[0]
      )
    )
    assert_equal Repository.count, 1
    post :create, repository: {name: 'code-curiosity', user: 'prasadsurase'}
    assert_equal Repository.count, 1
  end
end
