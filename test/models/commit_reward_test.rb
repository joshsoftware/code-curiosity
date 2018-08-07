require 'test_helper'

class CommitRewardTest < ActiveSupport::TestCase
  def setup
    @user  = create :user, auth_token: 'abcd1234', name: 'user'
    @budget = create :budget, start_date: Date.new(2018, 8, 1), end_date: Date.new(2018, 8, 31), amount: 310, is_all_repos: true

    @repository1 = create :repository, :language => 'Ruby', gh_repo_created_at: Date.today << 7, forks: 50, stars: 100
    @repository2 = create :repository, :language => 'Java', gh_repo_created_at: Date.today << 4, forks: 100, stars: 100

    create_list :commit, 3, user: @user, commit_date: Date.yesterday, repository: @repository1, lines: 50
    create_list :commit, 2, user: @user, commit_date: Date.today, repository: @repository2, lines:50
    create :commit, user: @user, commit_date: Date.today + 1, repository: @repository2, lines: 50
    create :commit, user: @user, commit_date: Date.today + 2, repository: @repository2, lines: 500
  end

  test 'checks if reward is calculated as per date' do
    CommitReward.new(Date.yesterday).calculate
    assert_equal day_commits(Date.yesterday)[0].score, 0.94
    assert_equal day_commits(Date.yesterday)[0].reward, 3.3

    CommitReward.new(Date.today).calculate
    assert_equal day_commits(Date.today)[0].score, 0.47
    assert_equal day_commits(Date.today)[0].reward, 5
  end

  test 'Reward should never exceed 5' do
    CommitReward.new(Date.today + 1).calculate
    assert_equal day_commits(Date.today + 1)[0].score, 0.47
    assert_equal day_commits(Date.today + 1)[0].reward, 5
  end

  test 'Carry Amount should not exceed 5' do
    CommitReward.new(Date.today + 1).calculate
    assert_equal day_commits(Date.today + 1)[0].score, 0.47
    assert_equal day_commits(Date.today + 1)[0].reward, 5

    @budget.reload

    CommitReward.new(Date.today + 2).calculate
    assert_equal @budget.carry_amount, 5
  end

  test 'Day Amount should not exceed 15' do
    CommitReward.new(Date.today + 1).calculate
    assert_equal day_commits(Date.today + 1)[0].score, 0.47
    assert_equal day_commits(Date.today + 1)[0].reward, 5

    @budget.reload

    CommitReward.new(Date.today + 2).calculate
    assert_equal @budget.day_amount, 15
  end

  test 'should check if transactions are created properly' do
    CommitReward.new(Date.yesterday).calculate
    @user.reload
    assert_equal @user.transactions[0].type, "credit"
    assert_equal @user.transactions[0].transaction_type, "daily reward"
    assert_equal @user.points, 2
    assert_equal @user.transactions[0].points, 9
  end

  test 'should check if badge is updated' do
    CommitReward.new(Date.yesterday).calculate
    @user.reload
    assert_equal @user.badges, { "Ruby" => 2.82 }
  end

  private

  def current_date_range(date)
    date.beginning_of_day..date.end_of_day
  end

  def day_commits(date)
    Commit.where(commit_date: current_date_range(date))
  end   
end
