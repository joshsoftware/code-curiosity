require "test_helper"

class InfoControllerTest < ActionController::TestCase
  
  test 'faq' do
    round = create(:round, status: 'open')
    get :faq
    assert_response :success
  end

end
