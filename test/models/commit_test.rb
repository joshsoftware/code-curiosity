require 'test_helper'

class CommitTest < ActiveSupport::TestCase

  def setup
    super
    create :round, :open
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

  def test_round_is_present
    commit = create(:commit, message: Faker::Lorem.sentences)
    assert commit.round.present?
  end

  def test_proper_round_is_assigned
    skip "pending feature"
    round_1 = create :round, from_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month
    round_2 = create :round, from_date: Date.today.beginning_of_month - 1.month, end_date: Date.today.end_of_month - 1.month
    commit_1 = create(:commit, message: Faker::Lorem.sentences, commit_date: Date.today, round: nil)
    assert_equal commit_1.round, round_1
    commit_2 = create(:commit, message: Faker::Lorem.sentences, commit_date: Date.today - 1.month, round: nil)
    assert_equal commit_2.round, round_2
  end

end
