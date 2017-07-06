require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def payment
    @payment ||= Payment.new
  end

  def test_valid
    assert payment.valid?
  end
end
