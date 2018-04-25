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

  test 'must return repositories which are valid for scoring' do
    create_list(:repository, 10, ignore: false)
    Repository.first.update_attributes(ignore: true)
    assert_not_equal Repository.count, Repository.required.count
  end

  test 'info should retrieve repository information' do
    repo = create :repository, name: 'mongoid-history', owner: 'aq1018', source_url: 'https://github.com/aq1018/mongoid-history'
    info = repo.info
    refute info.redirect?
    assert info.success?
  end

  test 'must return parent repositories' do
    repo = create :repository, type: 'popular', gh_id: 231232
    repository_1 = create :repository, popular_repository_id: repo.id, type: nil
    repository_2 = create :repository, source_gh_id: repo.gh_id, popular_repository_id: repo.id, type: nil
    assert_equal 1, Repository.parent.count
    assert_equal repo, Repository.parent.find_by(gh_id: 231232)
  end

  test 'must return child repositories whose parents are not present in DB' do
    repo = create :repository, type: 'popular', gh_id: 231232
    repository_1 = create :repository, type: nil
    repository_2 = create :repository, popular_repository_id: repo.id, type: nil
    assert_equal 2, Repository.parent.count
    assert_not_nil Repository.parent.find(repository_1.id)
  end

  test 'must not return any child repositories whose parent are present in DB' do
    repo = create :repository, type: 'popular', gh_id: 231232
    repository_1 = create :repository, popular_repository_id: repo.id, type: nil
    repository_2 = create :repository, source_gh_id: repo.gh_id, type: nil
    assert_equal 1, Repository.parent.count
    assert_not_nil Repository.parent.find(repo.id)
  end
end
