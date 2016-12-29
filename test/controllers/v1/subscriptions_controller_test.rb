require "test_helper"

class V1::SubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    @request.env['Accept'] = 'application/vnd.codecuriosity.org; version=1'
    @round = create :round, :open
    @goal = create :goal
    @user = create :user, auth_token: 'dah123rty', goal: @goal
    @subscription = @user.subscriptions.last
    assert_equal 1, @user.subscriptions.count
  end

  test 'response is success' do
    get :index, format: :json, id: @user.id
    assert_response :success
  end

  test "current user's subscriptions are retrieved" do
    get :index, format: :json, id: @user.id
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 1, data.size
    @user.subscriptions.pluck(:id).each do |id|
      assert_includes data.collect{|i| i['id']}, id.to_s
    end
  end

  test 'doesnt retrieve subscriptions of other users' do
    user = create :user, auth_token: 'dah123', goal: @goal
    assert_equal 1, user.subscriptions.count
    assert_equal 2, Subscription.count
    get :index, format: :json, id: user.id
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 1, data.size
    @user.subscriptions.pluck(:id).each do |id|
      refute_includes data.collect{|i| i['id']}, id.to_s
    end
  end

end
