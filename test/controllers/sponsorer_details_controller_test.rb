require "test_helper"
require "stripe_mock"

class SponsorerDetailsControllerTest < ActionController::TestCase

  before(:all) do
    round = create(:round, :status => 'open')
    @user = create(:user, :auth_token => 'dah123rty')
    StripeMock.start
  end

  after(:all) do
    StripeMock.stop
  end

  test "should not render index to not-logged in user" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should render index to logged-in user who is sponsor" do
    @user.is_sponsorer = true
    role = create(:role, name: 'Sponsorer')
    @user.roles << role
    @user.save
    sign_in @user
    get :index
    assert_response :success
  end

  test "should skip set goal for every action related to sponsor" do

  end

  test "should be compulsory to set goal if sponsor want to access pages other than sponsor" do
    @user.is_sponsorer = true
    role = create(:role, name: 'Sponsorer')
    @user.roles << role
    @user.save
    sign_in @user
    old_controller = @controller
    @controller = DashboardController.new
    get :index
    assert_redirected_to goals_path
    @controller = ActivitiesController.new
  end

  test "creates a valid stripe customer with subscription" do
    file = fixture_file_upload("#{Rails.root}/test/fixtures/rails.png", "image/png")
    sign_in(@user)

    stripe_helper = StripeMock.create_test_helper

    stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')

    assert_difference 'SponsorerDetail.count' do
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: file, publish_profile: "1", payment_plan: "base" },
        stripeToken: stripe_helper.generate_card_token(last4: '4242', exp_year: Time.now.year + 1), stripeEmail: @user.email
      @sponsor = SponsorerDetail.all[-1]
      assert_equal @sponsor.user.email, @user.email
      assert_not_nil @sponsor.stripe_customer_id
      assert_not_nil @sponsor.stripe_subscription_id
      assert_not_nil @sponsor.subscribed_at
      assert_not_nil @sponsor.subscription_expires_at
      assert_not_nil @sponsor.subscription_status
    end
  end

  test "does not create subscription if form data is not valid" do
    sign_in @user
    stripe_helper = StripeMock.create_test_helper

    stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')

    assert_difference 'SponsorerDetail.count', 0 do
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: nil, publish_profile: "1", payment_plan: "abc" },
        stripeToken: stripe_helper.generate_card_token(last4: '4242', exp_year: Time.now.year + 1), stripeEmail: @user.email
    end
    assert_not_nil flash[:error]
  end

  test "does not create sponsorer if error while creating stripe subscription" do
    file = fixture_file_upload("#{Rails.root}/test/fixtures/rails.png", "image/png")
    sign_in @user
    stripe_helper = StripeMock.create_test_helper

    stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')

    assert_difference 'SponsorerDetail.count', 0 do
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: file, publish_profile: "1", payment_plan: "base" },
        stripeToken: 'invalid_token1', stripeEmail: @user.email
    end
    assert_not_nil flash[:error]
  end

  test "redirect to sponsorer dashboard on save" do
    file = fixture_file_upload("#{Rails.root}/test/fixtures/rails.png", "image/png")
    sign_in(@user)
    stripe_helper = StripeMock.create_test_helper

    stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')

    assert_difference 'SponsorerDetail.count' do
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: file, publish_profile: "1", payment_plan: "base" },
        stripeToken: stripe_helper.generate_card_token(last4: '4242', exp_year: Time.now.year + 1), stripeEmail: @user.email
    end
    assert_redirected_to sponsorer_details_path
    assert_equal flash[:notice], 'saved sponsorship details successfully'
  end

  test "should send a mail after sponsorer is successfully created" do
    file = fixture_file_upload("#{Rails.root}/test/fixtures/rails.png", "image/png")
    sign_in(@user)
    stripe_helper = StripeMock.create_test_helper

    stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')

    assert_enqueued_jobs 2 do
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: file, publish_profile: "1", payment_plan: "base" },
        stripeToken: stripe_helper.generate_card_token(last4: '4242', exp_year: Time.now.year + 1), stripeEmail: @user.email
    end
  end

end
