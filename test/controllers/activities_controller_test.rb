require "test_helper"

class ActivitiesControllerTest < ActionController::TestCase
  let(:goal) { create :goal }
  let(:repo) { create :repository_with_activity_and_commits }
  let(:user) { create :user, auth_token: 'dah123rty', goal: goal }
  let(:other_user) { create :user, auth_token: 'dsadasda', goal: goal }

  before :all do
    @round = create :round, status: :open
  end

  test 'should not render index for non-logged-in users' do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'should render index for logged-in users' do
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  test 'should retrieve commits only associated to the current user' do
    create_list :commit, 15, user: user, repository: repo
    other = create :commit, user: other_user, repository: repo
    sign_in user

    get :index
    assert assigns(:commits).count, 15
    assert_not assigns(:commits).include?(other)
  end

  test 'should retrieve commits only for the current round' do
    create_list :commit, 15, user: user, repository: repo
    @round.update({status: 'inactive'})
    round = create(:round, status: 'open')
    sign_in user
    get :index
    assert assigns(:commits).count, 0
  end

  test 'should retrive commits in descending order of commit_date' do
    skip 'pending'
  end

  test 'should retrive commits for the requested page' do
    skip 'pending'
  end

  test 'should retrieve activities only associated to the current user' do
    create_list :activity, 15, :issue, user: user
    other = create :activity, :issue, user: other_user
    sign_in user

    get :index
    assert assigns(:activities).count, 15
    assert_not assigns(:activities).include?(other)
  end

  test 'should retrieve activities only for the current round' do
    create_list :activity, 15, :issue, user: user
    @round.update({status: 'inactive'})
    round = create(:round, status: 'open')
    sign_in user
    get :index
    assert assigns(:activities).count, 0
  end

  test 'should retrive activities in descending order of commented_on' do
    skip 'pending'
  end

  test 'should retrive activities for the requested page' do
    skip 'pending'
  end

end
