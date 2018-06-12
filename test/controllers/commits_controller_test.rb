require "test_helper"

describe CommitsController do
  before do
    user  = create :user, :auth_token => 'dah123rty'
    5.times.each do |i|
      create :commit, user: user, commit_date: Date.today, message: "commit_#{i}"
    end
    sign_in user
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_template partial: '_commits_table'
    assert_template partial: '_commits'
    assert_equal assigns(:commits).count, 5
  end

  describe 'date range is not provided' do
    test "should display current month's commits" do
      get :index
      assert_equal assigns(:commits).count, 5
    end
  end

  test 'should display commits between two dates' do
    get :index, {from: Date.yesterday - 1, to: Date.yesterday}
    assert_equal assigns(:commits).count, 0
  end

  test 'should search commits by search query' do
    get :index, {query: 'commit_1'}
    assert_equal assigns(:commits).count, 1
  end

  test 'should display commits between two dates and search by query' do
    get :index, {from: Date.yesterday - 1, to: Date.yesterday, query: 'commit'}
    assert_equal assigns(:commits).count, 0
  end
end
