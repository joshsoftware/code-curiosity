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

  test "sponsor should have one sponsorer_detail" do

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
