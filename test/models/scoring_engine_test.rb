require 'test_helper'

class ScoringEngineTest < ActiveSupport::TestCase
  def setup
    super
    @round = create :round, :open
    @repo = create :repository, name: 'dummy', owner: 'prasadsurase', ssh_url: 'git@github.com:prasadsurase/dummy.git'
    @commit = create :commit, repository: @repo, sha: '6cc7ecd9306a04fa4b084c184d89b8a21b6a5854'
    stub_get("/repos/prasadsurase/dummy/commits/6cc7ecd9306a04fa4b084c184d89b8a21b6a5854")
    .to_return(body: File.read('test/fixtures/dummy-commit.json'), status: 200,
    headers: {content_type: "application/json; charset=utf-8"})
  end

  def teardown
    super
    repo_path = "#{Rails.root.join(SCORING_ENGINE_CONFIG[:repositories]).to_s}/#{@repo.id}"
    FileUtils.rm_r(repo_path)if Dir.exists?(repo_path)
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

  test 'fetch_repo clones the repo if it doesnt exist' do
    engine = ScoringEngine.new(@repo)
    assert_nil = engine.git
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
  end

  test 'fetch_repo updates the repo if it exists' do
    engine = ScoringEngine.new(@repo)
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    # checkout to initial commit and check the master's sha.
    engine.git.reset_hard('546c6e578c16c24b0c24546e01ba0ecedd71b3af') # initial commit
    assert_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
    # pull again and confirm that thats not the latest sha(pull was successfull).
    engine.fetch_repo
    refute_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
  end

  test 'fetch_repo deletes and clones the repo if it exists' do
    engine = ScoringEngine.new(@repo)
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    # checkout to initial commit and check the master's sha.
    engine.git.reset_hard('546c6e578c16c24b0c24546e01ba0ecedd71b3af') # initial commit
    assert_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
    Git::Base.any_instance.stubs(:pull).with('origin', 'master').raises(Git::GitExecuteError, {})
    #FileUtils.expects(:rm_r).with("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}").returns(true)
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    # pull again and confirm that thats not the latest sha (deletion and clone was successfull).
    refute_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
  end

  test 'bugspots_score returns 0 if commit info is not present' do
    Commit.any_instance.stubs(:info).returns(nil)
    engine = ScoringEngine.new(@repo)
    assert_equal 0, engine.bugspots_score(@commit)
  end

  test 'bugspots_score of unwanted files should always be 0' do
    skip 'needs implementation'
    assert INVALID_FILES.include?('Gemfile.lock')
    engine = ScoringEngine.new(@repo)
    engine.bugspots_score(@commit)
  end
end
