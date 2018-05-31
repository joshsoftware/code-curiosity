require "test_helper"

class InfoControllerTest < ActionController::TestCase

  test 'faq' do
    get :faq
    assert_response :success
  end

end
