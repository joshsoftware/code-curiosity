require 'test_helper'

class CommitTest < ActiveSupport::TestCase

  def test_commit_message_should_be_unique
    commit = create(:commit, message: Faker::Lorem.words, commit_date: Time.now)
    messaging_time = commit.commit_date
    commit_message = commit.message
    new_commit = build(:commit, message: commit_message, commit_date: messaging_time)
    new_commit.save
    assert_not_empty new_commit.errors[:message]
  end

  def test_commit_count_of_user_is_zero_before_any_commit
    commit = build(:commit, message: Faker::Lorem.sentences)
    commits_count = commit.user.commits_count
    assert_equal commits_count, 0
  end

  def test_commit_count_of_user_is_incremented_after_every_commit
    commit = create(:commit, message: Faker::Lorem.sentences)
    commits_count = commit.user.commits_count
    assert_equal commits_count, 1
  end

  def test_maxmimum_commit_ratings_should_be_five
    commit = build(:commit, message: Faker::Lorem.sentences)
    max_rate = 5
    assert_equal commit.max_rating, max_rate
  end

  def test_commit_info
    commit = create(:commit, message: Faker::Lorem.sentences, sha: 'master', repository: create(:repository, owner: 'plataformatec', name: 'devise'))
    assert_not_nil commit.info
  end
end
