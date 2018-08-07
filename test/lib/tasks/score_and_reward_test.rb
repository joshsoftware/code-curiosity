require 'test_helper'

class ScoreAndRewardTest < ActiveSupport::TestCase
  setup do
    CodeCuriosity::Application.load_tasks
  end

  def test_score_and_reward_calculations
    repo = create :repository, name: 'tanya-josh', owner: 'tanya-saroha', language: 'Ruby', stars: 200, forks: 500, watchers: 500, gh_repo_created_at: Date.today << 4
    user = create  :user, github_handle: 'tanya-saroha', created_at: Date.yesterday - 1 
    commit = create :commit, message: 'commit1', repository_id: repo.id, commit_date: Date.yesterday, lines: 10
    budget = create :budget, start_date: Date.today - 30, end_date: Date.today, amount: 310, is_all_repos: true

    assert_nil commit.score
    assert_nil commit.reward

    Rake::Task['score_and_reward'].invoke
    commit.reload
    assert_equal commit.score, 0.6
    assert_equal commit.reward, 10
  end
end
