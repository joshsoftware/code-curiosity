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

  test "payment plan must be present" do
    sponsorer_detail = build(:sponsorer_detail, :payment_plan => nil)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:payment_plan].include?("can't be blank")
  end

  # test "publish profile flag must be boolean" do
  #   sponsorer_detail = build(:sponsorer_detail, :publish_profile => "string")
  #   sponsorer_detail.valid?
  #   binding.pry
  #   assert sponsorer_detail.errors[:publish_profile].include?("is not included in the list")
  # end

  test "sponsorer_detail must belong to user" do
    sponsorer_detail = build(:sponsorer_detail)
    sponsorer_detail.user = nil
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:user].include?("can't be blank")
  end

  test "profile photo or organization logo is not compulsory" do
    sponsorer_detail = build(:sponsorer_detail, :avatar => nil)
    sponsorer_detail.valid?
    assert sponsorer_detail.errors[:avatar].blank?
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

  test 'save_payment_details should create the payment record' do
    round = create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months, points: 500
    create(:subscription, round: round, user: user)
    sponsorer_detail = create(:sponsorer_detail, user: user)
    assert_equal 0, sponsorer_detail.payments.count
    assert_equal 0, user.transactions.count
    assert_equal 500, user.reload.points
    StripeMock.start
    stripe_helper = StripeMock.create_test_helper(:mock)
    plan = stripe_helper.create_plan(amount: 15000, name: 'base', id: 'base-organization', interval: 'month', currency: 'usd')
    sponsorer_detail.save_payment_details(plan, 10000, Time.now - 2.days)
    assert_equal 1, sponsorer_detail.payments.count
    StripeMock.stop
  end

  test "must save a new sponsorer with all params" do
    assert_difference 'SponsorerDetail.count' do
      create(:sponsorer_detail)
    end
  end

  test "must update royalty bonus amount for user if user took subscription within 1 month after sign up" do
    user = create :user, created_at: DateTime.parse("01/09/2017")
    transaction = create :transaction, created_at: DateTime.parse("01/09/2017"), transaction_type: 'royalty_bonus', type: 'credit', points: 200, user: user
    assert_equal 10, transaction.reload.amount
    sponsorer_detail = create :sponsorer_detail, created_at: DateTime.parse("05/09/2017"), sponsorer_type: 'INDIVIDUAL', user: user
    assert_equal 20, transaction.reload.amount
  end

  test "must not update royalty bonus amount for user if user took subscription after 1 month after sign up" do
    user = create :user, created_at: DateTime.parse("01/09/2017")
    transaction = create :transaction, created_at: DateTime.parse("01/09/2017"), transaction_type: 'royalty_bonus', type: 'credit', points: 200, user: user
    assert_equal 10, transaction.reload.amount
    sponsorer_detail = create :sponsorer_detail, created_at: DateTime.parse("05/10/2017"), sponsorer_type: 'INDIVIDUAL', user: user
    assert_equal 10, transaction.reload.amount
  end

  test "must only revert any active redeem request made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :redeem_request, created_at: DateTime.parse("30/07/2017"), points: 200, user: user
    assert_equal 1,user.redeem_requests.count
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("01/08/2017")
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user
    create :redeem_request, created_at: DateTime.parse("03/08/2017"), points: 200, user: user, sponsorer_detail: sponsorer_detail
    assert_equal 2, user.redeem_requests.count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 1, user.reload.redeem_requests.count
  end

  test "must not revert any completed redeem request made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("01/08/2017")
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user
    redeem_request = create :redeem_request, created_at: DateTime.parse("03/08/2017"), points: 200, user: user, sponsorer_detail: sponsorer_detail
    redeem_request.update(status: true)
    assert_equal 1, user.redeem_requests.count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 1, user.redeem_requests.count
  end

  test "must not revert any active redeem request not made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user
    redeem_request = create :redeem_request, created_at: DateTime.parse("03/08/2017"), points: 200, user: user
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("01/10/2017")
    assert_equal 1, user.redeem_requests.count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 1, user.redeem_requests.count
  end

  test "must not revert any completed redeem request not made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user
    redeem_request = create :redeem_request, created_at: DateTime.parse("03/08/2017"), points: 200, user: user
    redeem_request.update(status: true)
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("08/09/2017")
    assert_equal 1, user.redeem_requests.count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 1, user.redeem_requests.count
  end

  test "must not revert any credit transactions made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user, created_at: DateTime.parse("08/09/2017")
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user, created_at: DateTime.parse("30/09/2017")
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("08/09/2017")
    assert_equal 2, user.transactions.where(type: 'credit').count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 2, user.transactions.where(type: 'credit').count
  end

  test "must not revert any credit transactions not made during sponsorship" do
    round = create :round, :open
    user = create :user
    create(:subscription, round: round, user: user)
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user, created_at: DateTime.parse("08/08/2017")
    create :transaction, transaction_type: 'round', type: 'credit', points: 200, user: user, created_at: DateTime.parse("30/08/2017")
    sponsorer_detail = create :sponsorer_detail, user: user, created_at: DateTime.parse("08/09/2017")
    assert_equal 2, user.transactions.where(type: 'credit').count
    sponsorer_detail.update(subscription_status: 'canceled')
    assert_equal 2, user.transactions.where(type: 'credit').count
  end
end
