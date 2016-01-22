require "test_helper"

class TransactionTest < ActiveSupport::TestCase

  test "transaction type must be present" do
    transaction = build(:transaction,:type => nil)
    transaction.valid?
    assert_not_empty transaction.errors[:type]
  end

  test "points must be present" do 
    transaction = build(:transaction,:points => nil)
    transaction.valid?
    assert_not_empty transaction.errors[:points]
  end

end
