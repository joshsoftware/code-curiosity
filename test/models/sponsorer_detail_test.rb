require "test_helper"

class SponsorerDetailTest < ActiveSupport::TestCase
  
  test "sponsorer type must be present in sponsorer_detail" do
    sponsorer_detail = build(:sponsorer_detail, :sponsorer_type => nil)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:sponsorer_type].include?("can't be blank")
  end

  test "sponsorer type should be either INDIVIDUAL or ORGANIZATION" do
    sponsorer_detail = build(:sponsorer_detail, :sponsorer_type => "individual")
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:sponsorer_type].include?("is not included in the list")
  end

  test "payment plan must be numeric" do
    sponsorer_detail = build(:sponsorer_detail, :payment_plan => "string")
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:payment_plan].include?("is not a number")
  end

  test "payment plan must be greater than zero" do
    sponsorer_detail = build(:sponsorer_detail, :payment_plan => 0)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:payment_plan].include?("must be greater than 0")
  end

  # test "publish profile flag must be boolean" do
  #   sponsorer_detail = build(:sponsorer_detail, :publish_profile => "string")
  #   sponsorer_detail.valid?
  #   binding.pry
  #   assert sponsorer_detail.errors[:publish_profile].include?("is not included in the list")
  # end

  test "sponsorer_detail must belong to user" do
    sponsorer_detail = build(:sponsorer_detail, :user => nil)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:user].include?("can't be blank")
  end

  test "profile photo or organization logo must be present" do
    sponsorer_detail = build(:sponsorer_detail, :avatar => nil)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:avatar].include?("can't be blank")
  end

  test "user should upload only image as profile photo" do
    sponsorer_detail = build(:sponsorer_detail, :avatar => 
      File.new(Rails.root.join('test', 'fixtures', 'test.csv')))
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:avatar_content_type].include?("is invalid")
    assert sponsorer_detail.errors[:avatar_file_name].include?("is invalid")
    assert sponsorer_detail.errors[:avatar].include?("is invalid")
  end

  test "user must be updated as sponsorer after creating sponsorer details" do
    sponsorer_detail = create(:sponsorer_detail)
    user = sponsorer_detail.user
    assert user.is_sponsorer
    assert user.roles.where(name: 'Sponsorer').any?
  end

  test "must save a new sponsorer with all params" do
    assert_difference 'SponsorerDetail.count' do
      sponsorer = create(:sponsorer_detail)
    end
  end

end
