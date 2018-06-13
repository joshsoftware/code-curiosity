require 'test_helper'

class SetTest < ActiveSupport::TestCase
  test 'assign auto_score to score' do
    commit = create :commit, auto_score: 2
    assert_not_equal commit.score, commit.auto_score
    Rake::Task['set:score'].invoke
    commit.reload
    assert_equal commit.score, commit.auto_score
  end
end
