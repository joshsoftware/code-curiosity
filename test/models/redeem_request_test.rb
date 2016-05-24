require "test_helper"

class RedeemRequestTest < ActiveSupport::TestCase
  def redeem_request
    @redeem_request ||= RedeemRequest.new
  end

  def test_valid
    assert redeem_request.valid?
  end
end
