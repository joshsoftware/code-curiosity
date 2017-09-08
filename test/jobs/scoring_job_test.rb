require 'test_helper'

class ScoringJobTest < ActiveJob::TestCase
  def setup
    super
    @user = create :user, github_handle: 'prasadsurase', auth_token: 'somerandomtoken'
    @repo = create(:repository, owner: 'prasadsurase', name: 'code-curiosity')
    @user.repositories << @repo
    @round = create :round, :open
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
    assert @user.auth_token.present?
    assert_equal 1, User.count
  end

  test 'perform' do
    ScoringJob.perform_later(@repo.id.to_s, @round.id.to_s, 'commits')
    assert_enqueued_jobs 1
    ScoringJob.perform_later(@repo.id.to_s, @round.id.to_s, 'activities')
    assert_enqueued_jobs 2
  end

  test 'score activities' do
    message = 'some title and description of the issue'
    create_list(:activity, 3, description: message, event_type: 'issue', event_action: 'opened', auto_score: nil, user: @user)
    assert_equal 3, @user.activities_count
    ScoringJob.perform_now(@repo.id.to_s, @round.id.to_s, 'activities')
    @repo.activities.each do |activity|
      refute_nil activity.auto_score
    end
  end

end
