require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  def setup
    create :round, :open
  end

  test "repository name must be present" do
    repo = build(:repository,:name => nil)
    repo.valid?
    assert_not_empty repo.errors[:name]
  end

  test "repository source url must be present" do
    repo = build(:repository,:source_url => nil)
    repo.valid?
    assert_not_empty repo.errors[:source_url]
  end

  test "source url must be of valid format" do
    repo = build(:repository,:source_url => Faker::Internet.url)
    assert_no_match /\A(https|http):\/\/github.com\/[\.\w-]+\z/ , repo.source_url
  end

  test 'merge commit should be scored only 0' do
    repo = create :repository
    create :commit, repository: repo, message: 'merge pull request'
    create :commit, repository: repo, message: 'merge branch request'
    assert_equal 2, Commit.count
    repo.commits.each do |commit|
      assert_nil commit.auto_score
    end

    repo.score_commits
    repo.reload
    repo.commits.each do |commit|
      assert_equal 0, commit.auto_score
    end
  end

end
