require "test_helper"

class SponsorerDetailsControllerTest < ActionController::TestCase
  
  before(:all) do
    round = create(:round, :status => 'open')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
  end

  test "should not render index to not-logged in user" do
    get :index
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  # test "should not render index to normal user" do
  #   sign_in @user
  #   get :index
  #   assert_response :redirect
  # end

  test "should render index to logged-in user who is sponsor" do
    @user.is_sponsorer = true
    role = create(:role, name: 'Sponsorer')
    @user.roles << role
    @user.save
    sign_in @user
    get :index
    assert_response :success
  end

  test "redirect to sponsorer dashboard on save" do
    file = fixture_file_upload("#{Rails.root}/test/fixtures/rails.png", "image/png")
    sign_in(@user)
    assert_difference 'SponsorerDetail.count' do 
      #create(:sponsorer_detail, user: @user)
      post :create, sponsorer_detail: { sponsorer_type: "ORGANIZATION", avatar: file,publish_profile: "1", payment_plan: "200" }
    end
    assert_redirected_to sponsorer_details_path
  end

  #test case for handling unsuccessful form submit
end
