require 'test_helper'

class SetTest < ActiveSupport::TestCase
  test 'assign auto_score to score' do
    commit = create :commit, auto_score: 2
    assert_not_equal commit.score, commit.auto_score
    Rake::Task['set:score'].invoke
    commit.reload
    assert_equal commit.score, commit.auto_score
  end

  test 'set gh_repo_created_at for all repos' do
    GitApp.stubs(:info).returns(GITHUB)
    repo = create(:repository, name: 'code-curiosity', owner: 'joshsoftware')
    assert_nil repo.gh_repo_created_at
    Rake::Task['set:gh_repo_created_at'].execute
    repo.reload
    assert_not_nil repo.gh_repo_created_at
  end

  describe 'catch exception in case invalid repo or github error' do
    test 'do not set gh_repo_created_at' do
      # invalid repo name and owner
      create_list(:repository, 2, owner: 'abc')
      assert_equal Repository.where(gh_repo_created_at: nil).count, 2
      Rake::Task['set:gh_repo_created_at'].execute
      assert_equal Repository.where(gh_repo_created_at: nil).count, 2
    end
  end
end
