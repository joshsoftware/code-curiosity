require "test_helper"

class SponsorTest < ActiveSupport::TestCase
  test 'name must be present' do
    sponsor = build(:sponsor, name: '')
    sponsor.valid?
    assert_not_empty sponsor.errors[:name]
  end

  test 'name must be unique' do
    sponsor_1 = create(:sponsor, name: 'sample')
    sponsor_2 = build(:sponsor, name: 'sample')
    sponsor_2.valid?
    assert_not_empty sponsor_2.errors[:name]
  end
end
