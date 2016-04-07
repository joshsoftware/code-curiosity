require "test_helper"

class InfoControllerTest < ActionController::TestCase
  def test_faq
    get :faq
    assert_response :success
  end

end
