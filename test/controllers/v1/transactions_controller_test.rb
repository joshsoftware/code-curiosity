require "test_helper"

class V1::TransactionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    @request.env['Accept'] = 'application/vnd.codecuriosity.org; version=1'
    @goal = create :goal
    @user = create :user, auth_token: 'dah123rty', goal: @goal
    @round = create :round, :open
    @redeem_request = create(:redeem_request, points: 50, retailer: 'other', address: 'pune', gift_product_url: Faker::Internet.url,
                             coupon_code: 'aitpune', user: @user)
    @transaction = @redeem_request.transaction
    @transactions = FactoryGirl.create_list(:transaction, 3, type: 'credit', transaction_type: 'Round', points: 1, user: @user)
    assert_equal 4, @user.transactions.count
  end

  test 'response is 401 for unauthenticated user' do
    get :index, format: :json
    assert_response 401
  end

  test 'response is success for authenticated user' do
    sign_in @user
    get :index, format: :json
    assert_response :success
  end

  test "current user's transactions are retrieved" do
    sign_in @user
    get :index, format: :json
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 4, data.size
  end

  test 'doesnt retrieve transactions of other users' do
    user = create :user, auth_token: 'dah123', goal: @goal
    transactions = FactoryGirl.create_list(:transaction, 3, type: 'credit', transaction_type: 'Round', points: 1, user: user)
    sign_in @user
    assert_equal 4, @user.transactions.count
    assert_equal 3, user.transactions.count
    assert_equal 7, Transaction.count
    get :index, format: :json
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 4, data.size
    user.transactions.pluck(:id).each do |id|
      refute_includes data.collect{|i| i['id']}, id.to_s
    end
  end

end
