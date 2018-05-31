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
    omniauthentication
    user = User.find_by name: 'test_user'
    #assert user.github_user_since
    assert_equal @date, user.github_user_since
  end

  test 'must return user which are contestants and not blocked' do
    user_1 = create :user, auto_created: false, blocked: false
    user_2 = create :user, auto_created: true, blocked: false
    user_3 = create :user, auto_created: false, blocked: true
    assert_includes User.contestants.allowed, user_1
    assert_equal 1, User.contestants.allowed.count
  end

  test 'must return user which are contestants' do
    user_1 = create :user, auto_created: false, blocked: false
    user_2 = create :user, auto_created: true, blocked: false
    user_3 = create :user, auto_created: false, blocked: true
    assert_includes User.contestants, user_1
    assert_includes User.contestants, user_3
    assert_equal 2, User.contestants.count
  end

  test 'must return user which are contestants and blocked' do
    user_1 = create :user, auto_created: false, blocked: false
    user_2 = create :user, auto_created: true, blocked: false
    user_3 = create :user, auto_created: false, blocked: true
    assert_includes User.contestants.blocked, user_3
    assert_equal 1, User.contestants.blocked.count
  end

  test 'append @ prefix in twitter handle if not present when updated' do
    user = create :user
    assert_nil user.twitter_handle
    user.update(twitter_handle: 'amitk301293')
    assert "@amitk301293", user.twitter_handle
  end

  test 'twitter handle must not be blank when updated' do
    user = create :user
    assert_nil user.twitter_handle
    user.reload.update(twitter_handle: "")
    assert_empty user.twitter_handle
    assert_not user.valid?
    user.reload.set(twitter_handle: "@amik301293")
    assert user.valid?
  end

  test 'twitter handle must not contain spaces when updated' do
    user = create :user
    user.set(twitter_handle: "@amitk")
    assert user.valid?
    user.update(twitter_handle: "@amitk 301293")
    assert_not user.valid?
  end

  test 'twitter handle must not contain special characters when updated' do
    user = create :user
    user.set(twitter_handle: "@amitk301293")
    user.update(twitter_handle: "@amitk#301293")
    assert_not user.valid?
  end

  test 'twitter handle length must be 15 or less when updated' do
    user = create :user
    user.update(twitter_handle: "@aswisdakimasdfeassdfsasdfsere")
    assert_not user.valid?
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
end
