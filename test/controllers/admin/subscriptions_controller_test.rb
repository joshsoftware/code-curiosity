require "test_helper"

class Admin::SubscriptionsControllerTest < ActionController::TestCase

  def setup
    @admin_role = create :role, :admin
    @goal = create :goal, points: 15
    @round = create :round, :open
  end

  test 'non logged-in user should not be abeled to list subscribers' do
    get :index
    assert_response :redirect
  end

  test 'should not access index if the current user is not an admin' do
    sign_in create :user, auth_token: 'dah123rty', goal: @goal
    get :index
    assert_response :redirect
  end

  test 'should access users index only if the user is admin' do
    user = create :user, auth_token: 'dah123rty', goal: @goal
    user.roles << @admin_role
    sign_in user
    get :index
    assert_response :success
  end

  test 'should list the subscribers' do
    subscribers = create_list(:user, 4, auth_token: Faker::Lorem.word, goal: @goal)
    subscribers.each do |user|
      create(:sponsorer_detail, user: user, sponsorer_type: "INDIVIDUAL", subscription_status: 'active')
    end
    user = create :user, auth_token: 'dah123rty', goal: @goal
    user.roles << @admin_role
    sign_in user
    get :index
    assert_equal 4, SponsorerDetail.count
  end
end
