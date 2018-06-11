require "test_helper"

class Admin::RedeemRequestsControllerTest < ActionController::TestCase

  test "must get users redemption requests" do
    seed_data
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
  end

  test "should not update redeem_request without any parameter" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_raises ActionController::ParameterMissing do
      put :update, :id => redeem_request.id
    end
  end

  test "must update redeem_requests when coupon_code is changed" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    updated_coupon_code = 'josh24'
    patch :update, :id => redeem_request.id, redeem_request: {:coupon_code => updated_coupon_code}
    redeem_request.reload
    assert_equal updated_coupon_code, redeem_request.coupon_code
    assert_response :redirect
  end

  test "must update redeem_requests when comment is changed" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    updated_comment = Faker::Lorem.word
    patch :update, :id => redeem_request.id, redeem_request: {:comment => updated_comment}
    redeem_request.reload
    assert_equal updated_comment, redeem_request.comment
    assert_response :redirect
  end

  test "should destroy redeem_request" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('RedeemRequest.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end

  test "should destroy transaction corresponding to redeem_request" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('Transaction.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end

  test "should render index template" do
    seed_data
    redeem_request = create(:redeem_request, :points => 10, user: @user)
    xhr :get, :index, format: :js,  :id => @user.id
    assert_response :success
    assert_template 'redeem_requests/index'
    assert_template 'redeem_requests/_tagtable'
    assert_template 'redeem_requests/_redeem_request'
  end

  test "status should either be open or close" do
    seed_data
    redeem_request = create(:redeem_request, :points => 10, user: @user)
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
    assert_not_nil assigns(:filter_params['status'])
  end

  test "on status open should render all whose status are open" do
    seed_data
    redeem_request = create_list(:redeem_request, 3, :points => 2, :status => false, user: @user)
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
    assert_not_nil assigns(:filter_params['status'])
    assert_equal redeem_request.count, 3
  end

  test "should generate a csv file" do
    seed_data
    redeem_request = create(:redeem_request, :points => 100, user: @user)
    get :download, params: { :status => "false" }
    assert_response :success
    assert_equal "text/csv; header = present;", response.content_type
    get :download, params: { :status => "true" }
    assert_response :success
    assert_equal "text/csv; header = present;", response.content_type
  end

  test "check header of csv file for status false" do
    seed_data
    redeem_request = create(:redeem_request, :points => 100, user: @user)
    get :download, params: { :status => "false" }
    assert_response :success
    attr = "User,Gift Shop,Store,Points,Cost,Date,Coupon Code,Address,Status".split(',')
    csv = CSV.parse response.body
    assert_equal csv[0],attr
  end

  test "check header of csv file for status true" do
    seed_data
    redeem_request = create(:redeem_request, :points => 100, user: @user)
    get :download, params: { :status => "true" }
    assert_response :success
    attr = "User,Gift Shop,Store,Points,Cost,Date,Coupon Code,Address,Status".split(',')
    csv = CSV.parse response.body
    assert_equal csv[0],attr
  end

  test "check fields of csv file for status true" do
    seed_data
    gift_shop = ["github","amazon","other"]
    store = [nil,"amazon.com","amazon.in","amazon.uk"]
    status = ["false","true"]
    redeem_request = create(:redeem_request, :points => 100, user: @user)
    get :download, params: { :status => "true" }
    assert_response :success
    csv = CSV.parse response.body
    assert_includes gift_shop, csv[1][1]
    assert_includes store, csv[1][2]
    assert_kind_of Fixnum, csv[1][3].to_i
    assert_not_equal csv[1][3].to_i, csv[1][4].to_i
    assert_includes status, csv[1][8]
  end

  test "check fields of csv file for status false" do
    seed_data
    gift_shop = ["github","amazon","other"]
    store = [nil,"amazon.com","amazon.in","amazon.uk"]
    status = ["false","true"]
    redeem_request = create(:redeem_request, :points => 100, user: @user)
    get :download, params: {:status => "false"}
    assert_response :success
    csv = CSV.parse response.body
    assert_includes gift_shop, csv[1][1]
    assert_includes store, csv[1][2]
    assert_kind_of Fixnum, csv[1][3].to_i
    assert_not_equal csv[1][3].to_i, csv[1][4].to_i
    assert_includes status, csv[1][8]
  end

  test "must get redeem requests for specified store" do
    seed_data
    redeem_request = create(:redeem_request, points: 10, status: false, store: 'amazon.in', user: @user)
    xhr :get, :index, format: :js, store: 'amazon.in', status: false
    assert_includes assigns(:redeem_requests), redeem_request
  end

  test "must not get redeem requests for unspecified store" do
    seed_data
    redeem_request = create(:redeem_request, points: 10, status: false, store: 'amazon.in', user: @user)
    xhr :get, :index, format: :js, redeem_request: {store: 'amazon.com', status: false}
    assert_not_includes assigns(:redeem_requests), redeem_request
  end

  test "when redeem_request is updated update redeem_request amount" do
    seed_data
    create(:transaction, :type => 'credit', :points => 200, user: @user)
    redeem_request = create(:redeem_request, store: nil, retailer: 'other',
      address: "House Number-168/17A, Freehold\r\nNear Shatabdi Public School\r\nSector-23,Sanjay Nagar\r\nGhaziabad-201002", gift_product_url: "https://github.myshopify.com/products/arctocat", points: 0, user: @user)
    assert_equal 1, RedeemRequest.count
    assert_equal 0, RedeemRequest.first.amount
    patch :update, id: redeem_request.id, redeem_request: {points: 300, coupon_code: "Order #67981"}
    assert_equal 15, RedeemRequest.first.amount
  end

  test "when redeem_request is updated update redeem_request amount in ratio 1:10 points if redeem_request has sponsorer_detail" do
    seed_data
    sponsorer_detail = create(:sponsorer_detail)
    create(:transaction, :type => 'credit', :points => 1000, user: @user)
    redeem_request = create(:redeem_request, store: nil, retailer: 'other',
      address: "House Number-168/17A, Freehold\r\nNear Shatabdi Public School\r\nSector-23,Sanjay Nagar\r\nGhaziabad-201002", gift_product_url: "https://github.myshopify.com/products/arctocat", points: 0, sponsorer_detail: sponsorer_detail, user: @user)
    assert_equal 1, RedeemRequest.count
    assert_equal 0, RedeemRequest.first.amount
    patch :update, id: redeem_request.id, redeem_request: {points: 300, coupon_code: "Order #67981"}
    assert_equal 30, RedeemRequest.first.amount
  end

  test "when redeem_request is updated update redeem_request amount in ratio 1:20 points if redeem_request has no sponsorer_detail" do
    seed_data
    create(:transaction, :type => 'credit', :points => 200, user: @user)
    redeem_request = create(:redeem_request, store: nil, retailer: 'other',
      address: "House Number-168/17A, Freehold\r\nNear Shatabdi Public School\r\nSector-23,Sanjay Nagar\r\nGhaziabad-201002", gift_product_url: "https://github.myshopify.com/products/arctocat", points: 0, user: @user)
    assert_equal 1, RedeemRequest.count
    assert_equal 0, RedeemRequest.first.amount
    patch :update, id: redeem_request.id, redeem_request: {points: 300, coupon_code: "Order #67981"}
    assert_equal 15, RedeemRequest.first.amount
  end

  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    @user.roles << role
    sign_in @user
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

  def parameters
    {"redeem_request"=>{'coupon_code' => 'josh12' ,'points' => '100'}}
  end

end
