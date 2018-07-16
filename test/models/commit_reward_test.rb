require 'test_helper'

class CommitRewardTest < ActiveSupport::TestCase
  def setup
    @user1  = create :user, :auth_token => 'abcd1234'
    @user1.name = 'user1'

    @user2 = create :user, :auth_token => 'abc1234'
    @user2.name = 'user2'

    @repository1 = create :repository, :language => 'Ruby'
    @repository2 = create :repository, :language => 'Java'

    3.times.each do |i|
      commit = create :commit, user: @user1, commit_date: Date.yesterday, repository: @repository1, score: 2, reward: 1
      @user1.commits << commit
    end

    2.times.each do |i|
      commit = create :commit, user: @user2, commit_date: Date.yesterday, repository: @repository2, score: 2.4, reward: 1.6
      @user2.commits << commit
    end
  end

  test 'should check if transactions are created properly' do
    CommitReward.new.send(:create_transaction)

    @user1.reload
    @user2.reload

    assert_equal @user1.transactions[0].type, "credit"

    assert_equal @user2.transactions[0].transaction_type, "daily reward"

    assert_equal @user1.points, 6
    assert_equal @user1.transactions[0].points, 3

    assert_equal @user2.points, 4
    assert_equal @user2.transactions[0].points, 3
  end

  test 'should check if badge is updated' do
    CommitReward.new.calculate

    @user1.reload

    assert_equal @user1.badges, { "Ruby" => @user1.points }
  end
end
