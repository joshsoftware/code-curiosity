require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "must save a new user with all params" do
    assert_difference 'User.count' do
      create(:user)
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
    create(:subscription, round: round)
    omniauthentication
    user = User.find_by name: 'test_user'
    #assert user.github_user_since
    assert_equal @date, user.github_user_since
  end

  test "user should not be able to redeem if user is not registered on github for atleast 6 months and on codecurisity for alteast 3 months" do
    create :round, :open
    user = create :user, github_user_since: Date.today
    assert_not user.able_to_redeem?
  end

  test "user should be able to redeem if user is registered on github for atleast 6 months and on codecurisity for alteast 3 months" do
    create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months
    assert user.able_to_redeem?
  end

  test "reset_points should move points to royalty points and set points to 0" do
    round = create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months, points: 500
    create(:subscription, round: round, user: user)
    assert_equal 0, user.transactions.count
    assert_equal 500, user.reload.points
    user.reset_points
    assert_equal 2, user.transactions.count
    assert_equal 1, user.transactions.where(points: 500, transaction_type: 'royalty_bonus', type: 'credit').count
    assert_equal 1, user.transactions.where(points: -500, transaction_type: 'redeem_points', type: 'debit').count
    assert_equal 0, user.reload.points
  end

  test 'active_sponsorer_detail should return the active sponsorer detail' do
    round = create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months, points: 500
    create(:subscription, round: round, user: user)
    sponsorer_detail = create(:sponsorer_detail, user: user, subscription_status: :active)
    assert_equal sponsorer_detail, user.active_sponsorer_detail
  end

  test 'sponsorer_detail should return the latest sponsorer detail' do
    round = create :round, :open
    user = create :user, github_user_since: Date.today - 6.months, created_at: Date.today - 3.months, points: 500
    create(:subscription, round: round, user: user)
    create(:sponsorer_detail, user: user, subscription_status: :canceled)
    sponsorer_detail_2 = create(:sponsorer_detail, user: user, subscription_status: :canceled)
    assert_equal sponsorer_detail_2, user.sponsorer_detail
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

end
