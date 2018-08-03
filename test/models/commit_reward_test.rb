require 'test_helper'

class CommitRewardTest < ActiveSupport::TestCase
  def setup
    @user  = create :user, auth_token: 'abcd1234', name: 'user'

    @repository1 = create :repository, :language => 'Ruby', :gh_repo_created_at => 5
    @repository2 = create :repository, :language => 'Java', :gh_repo_created_at => 5

    create_list :commit, 3, user: @user, commit_date: Date.yesterday, repository: @repository1, score: 3, reward: 1, lines: 50
    create_list :commit, 2, user: @user, commit_date: Date.today, repository: @repository2, score: 3, reward: 2, lines:50
  end

  test 'checks if reward is calculated as per date' do
    CommitReward.new(Date.yesterday).send(:create_transaction)
    @user.reload
    assert_equal @user.points, 9
    assert_equal @user.transactions[0].points, 3
    
    CommitReward.new(Date.today).send(:create_transaction)
    @user.reload
    assert_equal @user.points, 15
    assert_equal @user.transactions[1].points, 4
  end

  test 'should check if transactions are created properly' do
    CommitReward.new(Date.yesterday).send(:create_transaction)
    @user.reload
    
    assert_equal @user.transactions[0].type, "credit"
    assert_equal @user.transactions[0].transaction_type, "daily reward"
    assert_equal @user.points, 9
    assert_equal @user.transactions[0].points, 3
  end

  test 'should check if badge is updated' do
    CommitReward.new(Date.yesterday).calculate
    #binding.pry
    @user.reload
    assert_equal @user.badges, { "Ruby" => @user.points }
  end
end
