require "test_helper"

class V1::TransactionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    @request.env['Accept'] = 'application/vnd.codecuriosity.org; version=1'
    @user = create :user, auth_token: 'dah123rty'
    @transaction = create(:transaction, type: 'credit', points: 500, user: @user, transaction_type: 'royalty_bonus')
    @redeem_request = create(:redeem_request, points: 100, retailer: 'other', address: 'pune', gift_product_url: Faker::Internet.url,
                             coupon_code: 'aitpune', user: @user)
    @transaction = @redeem_request.transaction
    @transactions = FactoryGirl.create_list(:transaction, 2, type: 'credit', transaction_type: 'Round', points: 100, user: @user)
    assert_equal 4, @user.transactions.count
  end

  test 'response is success for unauthenticated user' do
    get :index, format: :json, id: @user.id
    assert_response :success
  end

  test 'response is success for authenticated user' do
    sign_in @user
    get :index, format: :json, id: @user.id
    assert_response :success
  end

  test "user's transactions are retrieved" do
    sign_in @user
    get :index, format: :json, id: @user.id
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 4, data.size
  end

  test 'doesnt retrieve transactions of other users' do
    user = create :user, auth_token: 'dah123'
    transactions = FactoryGirl.create_list(:transaction, 3, type: 'credit', transaction_type: 'Round', points: 1, user: user)
    sign_in @user
    assert_equal 4, @user.transactions.count
    assert_equal 3, user.transactions.count
    assert_equal 7, Transaction.count
    get :index, format: :json, id: @user.id
    assert_not_empty response.body
    data = JSON.parse(response.body)
    assert_equal 4, data.size
    user.transactions.pluck(:id).each do |id|
      refute_includes data.collect{|i| i['id']}, id.to_s
    end
  end

end
