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
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_nil engine.git
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    refute_nil engine.git
  end

  test 'fetch_repo clones the repo if it doesnt exist and checksout to the specified branch' do
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_nil engine.git
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo('feature')
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    refute_nil engine.git
    assert_equal 'feature', engine.git.branches.local.first.name
  end

  test 'fetch_repo updates the current repository branch if no branch is specified' do
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    assert_equal 'master', engine.git.branches.local.first.name
    # checkout to initial commit and check the master's sha.
    engine.git.reset_hard('546c6e578c16c24b0c24546e01ba0ecedd71b3af') # initial commit
    assert_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
    # pull again and confirm that thats not the latest sha(pull was successfull).
    engine.fetch_repo
    refute_equal '546c6e578c16c24b0c24546e01ba0ecedd71b3af', engine.git.object('master').sha
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    assert_equal 'master', engine.git.branches.local.first.name
  end

  test 'fetch_repo checksout to the specified branch and updates that repository branch' do
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    refute Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    engine.fetch_repo
    assert Dir.exists?("#{Rails.root.join(engine.config[:repositories]).to_s}/#{@repo.id}")
    assert_equal 'master', engine.git.branches.local.first.name

    engine.fetch_repo('feature')
    assert_equal 'feature', engine.git.branches.local.first.name

    engine.fetch_repo('development')
    assert_equal 'development', engine.git.branches.local.first.name
  end

  test 'bugspots_score returns 0 if commit info is not present' do
    Commit.any_instance.stubs(:info).returns(nil)
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_equal 0, engine.bugspots_score
  end

  test 'fetch_repo updates the repo if it exists' do
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
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
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
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

  test 'bugspots_score of unwanted files should always be 0' do
    skip 'needs implementation'
    assert INVALID_FILES.include?('Gemfile.lock')
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    engine.bugspots_score
  end

  test 'check comments_score of the commit' do
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_equal 0, @engine.comments_score
  end

  test 'check commit_score of the commit when no files are excluded during scoring' do
    stub_commit_for_bugspots_scoring
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_equal 273, @commit.info.stats.total
    assert_equal 1, @engine.commit_score
  end

  test 'check commit scoring should not be done for ignored_files' do
    stub_commit_for_bugspots_scoring
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    file_to_be_ignored = create :file_to_be_ignored, name: "Gemfile.lock", ignored: true
    @engine.bugspots_score
    assert_equal 1, file_to_be_ignored.reload.count
    assert_equal 103, @commit.info.stats.total
    assert_equal 2.25, @engine.commit_score
  end

  test 'check bugspots_score when no files are excluded during scoring ' do
    stub_commit_for_bugspots_scoring
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    assert_not_equal 0, @engine.bugspots_score
  end

  test 'check bugspots scoring when files are excluded' do
    stub_commit_for_bugspots_scoring
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    file_to_be_ignored = create :file_to_be_ignored, name: "Gemfile", ignored: true
    assert_equal 1, FileToBeIgnored.count
    assert_not_equal 0, @engine.bugspots_score
  end

  test 'check bugspots should not do scoring of files such as Gemfile.lock or README' do
    stub_commit_for_bugspots_scoring
    @engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    file_to_be_ignored = create :file_to_be_ignored, name: "Gemfile.lock", ignored: true

    Bugspots.stubs(:scan).returns(YAML.load(File.read("test/fixtures/bugspot.yml")))
    repo_dir = Rails.root.join("repositories", @repo.id.to_s).to_s
    bugspots = Bugspots.scan(repo_dir, "master").last

    bugspots_scores = bugspots.inject({}){|r, s| if (FileToBeIgnored.name_exist?(s.file)) then s.score = "0.0000" end; r[s.file] = s; r}
    max_score = bugspots_scores.max_by{|k,v| v.first.to_f}.last.score.to_f

    total_score = @commit.info.files.inject(0) do |result, file|
      file_score = bugspots_scores[file.filename]
      if file_score
        result += (bugspots_scores[file.filename].score.to_f * 5)/max_score
      end
      result
    end

    #without excluding any files, total_files_count is 10
    assert_equal 10, @commit.info.files.count

    #files_count after excluding files such as Gemfile.lock
    valid_files_count = 9

    scores = ([total_score/valid_files_count, 5].min)*(0.45)
    bugspot_score = @engine.bugspots_score
    assert_equal bugspot_score.round(3), scores.round(3)
  end

  test 'method should return nil if it is unable to clone repository' do
    repo = create :repository, ssh_url: 'git@github.com:prasadsurase/code-curiosity.git', owner: 'prasadsurase', name: 'code-curiosity'
    commit = create(:commit, message: Faker::Lorem.sentences, sha: '8a11b8031c06df55f0edf7d41aad22987a74165d', repository: repo)
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    Git.stubs(:clone).raises(Git::GitExecuteError, {})
    git = engine.send(:clone_repo)
    assert_nil git
  end

  test 'method should return git if it can clone repository' do
    repo = create :repository, ssh_url: 'git@github.com:prasadsurase/code-curiosity.git', owner: 'prasadsurase', name: 'code-curiosity'
    commit = create(:commit, message: Faker::Lorem.sentences, sha: '8a11b8031c06df55f0edf7d41aad22987a74165d', repository: repo)
    engine = ScoringEngine.new(commit: @commit.as_json, repository: @repo.as_json)
    git = engine.send(:clone_repo)
    assert_not_nil git
  end


  def stub_commit_for_bugspots_scoring
    @repo = create :repository, ssh_url: 'git@github.com:prasadsurase/code-curiosity.git', owner: 'prasadsurase', name: 'code-curiosity'
    @commit = create(:commit, message: Faker::Lorem.sentences, sha: '8a11b8031c06df55f0edf7d41aad22987a74165d', repository: @repo)
    stub_get('/repos/prasadsurase/code-curiosity/commits/8a11b8031c06df55f0edf7d41aad22987a74165d').to_return(
      body: File.read('test/fixtures/commit.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
  end
end
