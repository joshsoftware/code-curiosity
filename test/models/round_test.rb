require 'test_helper'

class RoundTest < ActiveSupport::TestCase

  test "must create round with all params" do
    assert_difference 'Round.count' do
      user = create(:round)
    end
  end

  test "name must be present" do
    round = build(:round,:name => nil)
    round.valid?
    assert_not_empty round.errors[:name]
  end


  test "from_date must be present" do
    round = build(:round,:from_date => nil)
    round.valid?
    assert_not_empty round.errors[:from_date] 
  end

  test "end_date must be after from_date" do
    round = build(:round)
    round.end_date = Time.now - 20.days
    round.valid?
    assert_not_empty round.errors[:end_date]
  end

end
