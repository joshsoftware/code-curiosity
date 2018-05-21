require "test_helper"

class CommitsControllerTest < ActionController::TestCase
  before do
    goal  = create :goal, points: 10
    round = create :round, :open
    user  = create :user, :auth_token => 'dah123rty', goal: goal
    5.times.each do
      create :commit, user: user, commit_date: Date.today
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

  test 'should fetch commits between two dates' do
    get :index, {from: Date.yesterday - 1, to: Date.yesterday, query: ''}
    assert_equal assigns(:commits).count, 0
  end
end
