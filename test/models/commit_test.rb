require 'test_helper'

class CommitTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    stub_get("/repos/joshsoftware/code-curiosity/commits/eb0df748bbf084ca522f5ce4ebcf508d16169b96")
    .to_return(body: File.read('test/fixtures/commit.json'), status: 200,
               headers: {content_type: "application/json; charset=utf-8"})
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

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
    commit = create(:commit, message: Faker::Lorem.sentences, sha: 'eb0df748bbf084ca522f5ce4ebcf508d16169b96', repository: create(:repository, owner: 'joshsoftware', name: 'code-curiosity'))
    assert_not_nil commit.info

    commit = create(:commit, message: Faker::Lorem.sentences, sha: 'eb0df748bbf084ca522f5ce4ebcf508d16169b96', repository: nil)
    assert_nil commit.info
  end


  def test_frequency_factor_without_previous_commit
    commit_1 = create(:commit, message: Faker::Lorem.sentences, commit_date: Date.today)
    assert_equal commit_1.frequency_factor, 1
  end

  def test_frequency_factor_with_previous_commit
    user = create(:user)
    25.times.each do |n|
      create(:commit, user: user, message: Faker::Lorem.sentences, commit_date: Date.today - (n + 1).day)
    end
    commit_1 = create(:commit, user: user, message: Faker::Lorem.sentences, commit_date: Date.today)
    assert_equal commit_1.frequency_factor > 1.0, true
  end

  def test_frequency_factor_should_not_be_negative
  end
end
