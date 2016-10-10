require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "must save a new user with all params" do
    assert_difference 'User.count' do
      user = create(:user)
    end
  end

  test "email address must be present" do
    user = build(:user,:email => nil)
    user.valid?
    assert_not_empty user.errors[:email]
  end

  test "name must be present" do
    user = build(:user,:name => nil)
    user.valid?
    assert_not_empty user.errors[:name]
  end

  test "github handle must be present" do
    user = build(:user,:github_handle => nil)
    user.valid?
    assert_not_empty user.errors[:github_handle]
  end

  test "github_user_since should not be nil" do
    round = create :round, :open
    subscription = create(:subscription, round: round)
    omniauthentication
    user = User.find_by name: 'test_user'
    #assert user.github_user_since
    assert_equal @date, user.github_user_since
  end

  test "user should not be able to redeem if user is not registered on github for atleast 6 months and on codecurisity for alteast 3 months" do
    round = create :round, :open
    user = create :user, github_user_since: Date.today
    assert_not user.able_to_redeem?
  end

  test "user should be able to redeem if user is registered on github for atleast 6 months and on codecurisity for alteast 3 months" do
    round = create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months
    assert user.able_to_redeem?
  end

  def omniauthentication
    @date = Date.new(2015, 10, 10)
    OmniAuth.config.test_mode = true
    omniauth_hash = {
      provider:  'github',
      uid: '12345',
      info: {
        name: 'test_user',
        email: 'test@test.com'
      },
      extra: {
        raw_info:
        {
          login: 'hello',
          created_at: @date
        }
      },
      credentials: {
        token: 'github_omiauth_test'
      }
    }
    @req_env = OmniAuth.config.add_mock(:github, omniauth_hash)
    User.from_omniauth(@req_env)
  end

  test 'deleted?' do
    user = build :user
    assert_not user.deleted?
    user.update({deleted_at: Time.now, active: false})
    assert user.deleted?
  end

  test 'set_royalty_bonus' do
    user = create :user
    user.expects(:calculate_royalty_bonus).returns(500)
    user.set_royalty_bonus
    assert_equal 1, user.transactions.count
    transaction = user.transactions.first
    assert_equal 'credit', transaction.type
    assert_equal 'royalty_bonus', transaction.transaction_type
    assert_equal 500, transaction.points
    assert_equal 500, user.total_points

    redeem_request_1 = create(:redeem_request, points: 100, address: 'baner', user: user)
    redeem_request_2 = create(:redeem_request, points: 250, address: 'baner', user: user)
    assert_equal 3, user.transactions.count

    user.expects(:calculate_royalty_bonus).returns(600)
    user.set_royalty_bonus
    assert_equal 4, user.transactions.count
    transaction = user.transactions.last
    assert_equal 'credit', transaction.type
    assert_equal 'royalty_bonus', transaction.transaction_type
    assert_equal 100, transaction.points
    assert_equal 250, user.total_points

    user.expects(:calculate_royalty_bonus).returns(900)
    user.set_royalty_bonus
    assert_equal 5, user.transactions.count
    transaction = user.transactions.last
    assert_equal 'credit', transaction.type
    assert_equal 'royalty_bonus', transaction.transaction_type
    assert_equal 300, transaction.points
    assert_equal 550, user.total_points
  end

end
