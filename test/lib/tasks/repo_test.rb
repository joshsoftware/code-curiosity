require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def setup
    @path = "#{Rails.root.join(SCORING_ENGINE_CONFIG[:repositories]).to_s}"
    @round = create :round, :open
    CodeCuriosity::Application.load_tasks
    Rake::Task['repo:delete_repository_dir'].reenable
    Dir.mkdir("#{@path}") unless Dir.exists?("#{@path}")
  end

  test 'must not delete repository directories whose commits are not scored yet' do
    repo_1 = create :repository
    Dir.mkdir("#{@path}/#{repo_1.id}")
    commit_1 = create :commit, auto_score: nil, repository: repo_1, round: @round
    commit_2 = create :commit, auto_score: nil, repository: repo_1, round: @round
    assert_includes Dir.entries(@path), repo_1.id.to_s
    Rake::Task['repo:delete_repository_dir'].invoke
    assert_includes Dir.entries(@path), repo_1.id.to_s
  end

  test 'must delete only those repository directories whose all commits are scored' do
    repo_1 = create :repository
    repo_2 = create :repository
    Dir.mkdir("#{@path}/#{repo_1.id}")
    Dir.mkdir("#{@path}/#{repo_2.id}")
    commit_1 = create :commit, auto_score: nil, repository: repo_1, round: @round
    commit_2 = create :commit, auto_score: nil, repository: repo_1, round: @round
    commit_3 = create :commit, auto_score: nil, repository: repo_2, round: @round
    commit_4 = create :commit, auto_score: nil, repository: repo_2, round: @round
    assert_includes Dir.entries(@path), repo_1.id.to_s
    assert_includes Dir.entries(@path), repo_2.id.to_s
    commit_1.update(auto_score: 0)
    commit_2.update(auto_score: 0)
    Rake::Task['repo:delete_repository_dir'].invoke
    assert_not_includes Dir.entries(@path), repo_1.id.to_s
    assert_includes Dir.entries(@path), repo_2.id.to_s
  end

  test 'must not delete repository directories whose some commits are not scored yet' do
    repo_1 = create :repository
    Dir.mkdir("#{@path}/#{repo_1.id}")
    commit_1 = create :commit, auto_score: nil, repository: repo_1, round: @round
    commit_2 = create :commit, auto_score: nil, repository: repo_1, round: @round
    assert_includes Dir.entries(@path), repo_1.id.to_s
    commit_1.update(auto_score: 0)
    Rake::Task['repo:delete_repository_dir'].invoke
    assert_includes Dir.entries(@path), repo_1.id.to_s
  end

end
