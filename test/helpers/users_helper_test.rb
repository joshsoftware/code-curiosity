require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test "show remove twitter handle prefix from twitter handle" do
    twitter_handle = "@amitk301293"
    assert_equal "amitk301293", remove_prefix(twitter_handle)
  end

  test 'must return sum amount of only debit transactions made by user' do
    user = create :user
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :transaction, transaction_type: 'Round', type: 'credit', points: 100, user: user
    create :transaction, transaction_type: 'redeem_points', type: 'debit', points: 200, user: user
    assert_equal 20, amount_earned(user)
  end

  test 'must return 0 if user has no debit transactions' do
    user = create :user
    create :transaction, transaction_type: 'royalty_bonus', type: 'credit', points: 1000, user: user
    create :transaction, transaction_type: 'Round', type: 'credit', points: 100, user: user
    assert_equal 0, amount_earned(user)
  end
end
