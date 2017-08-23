require "test_helper"

class ScoreCommitJobTest < ActiveJob::TestCase

  def setup
    @user = create :user, github_handle: 'amitk', auth_token: 'somerandomtoken'
    @repo = create :repository, name: 'code-curiosity', owner: @user
    @round = create :round, :open
    @commit = create :commit, auto_score: nil, user: @user
    @user.repositories << @repo
    @repo.commits << @commit
    @round.commits << @commit
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
    assert @user.auth_token.present?
    assert_equal 1, User.count
  end

  test 'perform' do
    ScoreCommitJob.perform_later(@commit.id.to_s)
    assert_enqueued_jobs 1
  end

  test 'must score commit' do
    ScoringEngine.any_instance.stubs(:calculate_score).with(@commit).returns(2)
    ScoreCommitJob.perform_now(@commit.id.to_s)
    assert_equal 1, Commit.count
    assert_equal 2, @commit.reload.auto_score
  end
end
