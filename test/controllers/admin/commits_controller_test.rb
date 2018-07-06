require 'test_helper'

describe CommitsController do
  before do
    user  = create :user, :auth_token => 'abc123'
    5.times.each do |i|
      create :commit, user: user, commit_date: Date.yesterday, message: "commit_#{i}"
    end
    sign_in user
  end

  test 'index' do
    get :index
    assert_response :success
    assert_template :index
    assert_template partial: '_commits_table'
    assert_template partial: '_commits'
    assert_equal assigns(:commits).count, 5
  end

  describe 'date range is not provided' do
    test "should display yesterday's commits" do
      get :index
      assert_equal assigns(:commits).count, 5
    end
  end

  describe 'date range is provided' do
    test 'should display commits between two dates: case 1' do
      get :index, {from: Date.yesterday - 1, to: Date.yesterday}
      assert_equal assigns(:commits).count, 5
    end

    test 'should display commits between two dates: case 2' do
      get :index, {from: Date.today, to: Date.today + 1}
      assert_equal assigns(:commits).count, 0
    end
  end

  describe 'query is provided' do
    test 'should search commits when search query present' do
      get :index, {query: '1'}
      assert_equal assigns(:commits).count, 1
    end
  
    test 'should display commits between two dates and search by query' do
      get :index, {from: Date.yesterday, to: Date.yesterday, query: 'commit'}
      assert_equal assigns(:commits).count, 5
    end
  end
end


