require 'test_helper'

class ScoreAndRewardTest < ActiveSupport::TestCase
  setup do
    CodeCuriosity::Application.load_tasks
  end

  def test_score_and_reward_calculations
    repo = create :repository, name: 'tanya-josh', owner: 'tanya-saroha', language: 'Ruby'
    user = create  :user, github_handle: 'tanya-saroha', created_at: Date.yesterday - 1 
    commit = create :commit, message: 'commit1', repository_id: repo.id

    assert_equal commit.score, 0
    assert_nil commit.reward

    Rake::Task['score_and_reward'].invoke
    commit.reload

    assert commit.score > 5
    assert commit.reward > 5
  end
end
