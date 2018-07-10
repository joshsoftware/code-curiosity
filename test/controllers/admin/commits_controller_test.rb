require 'test_helper'

describe CommitsController do
  before do
    user  = create :user, :auth_token => 'abc123'
    user.name = 'user'
    repository = create :repository
    user.repositories << repository
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

  describe 'date range is provided' do
    describe 'commits are present' do
      test 'should display commits between two dates' do
        get :index, {from: Date.yesterday - 1, to: Date.yesterday}
        assert_equal assigns(:commits).count, 5
      end

      test 'should search commits when user name present in search query' do
        get :index, {query: 'user'}
        assert_equal assigns(:commits).count, 5
      end

      test 'should search commits when repository name present in search query' do
        get :index, {query: 'repository'}
        assert_equal assigns(:commits).count, 0
      end

      test 'should search commits when description present in search query' do
        get :index, {query: '1'}
        assert_equal assigns(:commits).count, 1
      end
    end

    describe 'no commits are present' do
      test 'should return nothing' do
        get :index, {from: Date.today, to: Date.today + 1}
        assert_equal assigns(:commits).count, 0
      end

      test 'should give nothing when search query is present' do
        get :index, {query: 'tanya'}
        assert_equal assigns(:commits).count, 0
      end
    end
  end

  describe 'date range is not provided' do
    test 'should display commits of previous day' do
      get :index
      assert_equal assigns(:commits).count, 5
    end
  end
end



