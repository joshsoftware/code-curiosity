require "test_helper"

class OrgReposJobTest < ActiveJob::TestCase
  def setup
    super
    stub_get("/orgs/joshsoftware").to_return(
      body: File.read('test/fixtures/org.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read('test/fixtures/org-repos.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    @org = create :organization, last_repo_sync_at: nil, github_handle: 'joshsoftware'
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

  test 'perform' do
    OrgReposJob.perform_later(@org)
    assert_enqueued_jobs 1
  end

  test 'updates last_repo_sync_at time' do
    assert_nil @org.last_repo_sync_at
    OrgReposJob.any_instance.stubs(:add_repo).returns(true)
    OrgReposJob.perform_now(@org)
    refute_nil @org.last_repo_sync_at
  end

  test 'skip if unpopular and not a fork' do
    file_path = 'test/fixtures/org-unpopular-repos.json'
    repos = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    assert_equal 1, repos.count
    assert_equal 24, repos.first.stargazers_count
    refute repos.first.fork
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    assert_equal 0, Repository.count
    OrgReposJob.perform_now(@org)
    assert_equal 0, Repository.count
    assert_equal 0, @org.repositories.count
  end

  test 'skip if unpopular, is forked and remote is unpopular' do
    file_path = 'test/fixtures/org-unpopular-forked-repos.json'
    repos = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    assert_equal 1, repos.count
    assert_equal 2, repos.first.stargazers_count
    assert repos.first.fork
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(JSON.parse(File.read('test/fixtures/org-remote-unpopular-fork.json')))
    )
    assert_equal 0, Repository.count
    OrgReposJob.perform_now(@org)
    assert_equal 0, Repository.count
    assert_equal 0, @org.repositories.count
  end

  test 'persist if is popular and it not a fork' do
    file_path = 'test/fixtures/org-popular-repos.json'
    repos = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    assert_equal 1, repos.count
    assert_equal 30, repos.first.stargazers_count
    refute repos.first.fork
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    assert_equal 0, Repository.count
    OrgReposJob.perform_now(@org)
    assert_equal 1, Repository.count
    assert_equal 1, @org.repositories.count
    assert_equal 30, @org.repositories.first.stars
  end

  test 'persist if is popular and is a fork and remote is unpopular' do
    file_path = 'test/fixtures/org-popular-repos-with-unpopular-remotes.json'
    repos = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    assert_equal 1, repos.count
    assert_equal 25, repos.first.stargazers_count
    assert repos.first.fork
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    assert_equal 0, Repository.count
    OrgReposJob.perform_now(@org)
    assert_equal 1, Repository.count
    assert_equal 1, @org.repositories.count
    org_repo = @org.repositories.first
    assert_equal 25, org_repo.stars
    assert_nil org_repo.source_gh_id
  end

  test 'persist if unpopular, is a fork and remote is popular' do
    file_path = 'test/fixtures/org-unpopular-repos-with-popular-remotes.json'
    repos = JSON.parse(File.read(file_path)).collect{|i| Hashie::Mash.new(i)}
    assert_equal 1, repos.count
    assert_equal 24, repos.first.stargazers_count
    assert repos.first.fork
    stub_get('/orgs/joshsoftware/repos?per_page=100').to_return(
      body: File.read(file_path), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(JSON.parse(File.read('test/fixtures/org-popular-remote.json')))
    )
    assert_equal 0, Repository.count
    OrgReposJob.perform_now(@org)
    assert_equal 2, Repository.count
    assert_equal 1, @org.repositories.count
    org_repo = @org.repositories.first
    assert_equal 24, org_repo.stars
    assert_equal 316258, org_repo.source_gh_id
    parent_repo = Repository.asc(:created_at).first
    refute_equal org_repo, parent_repo
    assert_equal 148, parent_repo.stars
    assert_nil parent_repo.source_gh_id
  end

end

