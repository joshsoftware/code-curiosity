require "test_helper"

class WalletTest < ActiveSupport::TestCase
  def wallet
    @wallet ||= Wallet.new
  end

  def test_valid
    assert wallet.valid?
  end
end
