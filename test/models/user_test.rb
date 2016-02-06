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
end
