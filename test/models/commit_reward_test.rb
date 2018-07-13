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
      commit = create :commit, user: @user1, commit_date: Date.yesterday, repository: @repository1
      @user1.commits << commit
    end

    2.times.each do |i|
      commit = create :commit, user: @user2, commit_date: Date.yesterday, repository: @repository2
      @user2.commits << commit
    end
  end
    
  test 'should check if transactions are created properly' do
    result = CommitReward.new.calculate

    @user1.reload
    @user2.reload

    assert_not_equal @user1.points, nil
    assert_not_equal @user2.points, nil
    
    assert_not_equal @user1.transactions.first.type, nil

    assert_not_equal @user2.transactions.last.transaction_type, nil

    assert_not_equal @user1.commits.sum{|commit| commit.score}, nil

    assert_not_equal @user1.badges, {}
  end
end
