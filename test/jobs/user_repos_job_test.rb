require "test_helper"

class UserReposJobTest < ActiveJob::TestCase
  def setup
    super
    @user = create :user, github_handle: 'prasadsurase', auth_token: 'somerandomtoken'
    clear_enqueued_jobs
    clear_performed_jobs
    assert_no_performed_jobs
    assert_no_enqueued_jobs
    assert @user.auth_token.present?
    assert_equal 1, User.count
    stub_get('/users/prasadsurase/repos?per_page=100').to_return(
      body: File.read('test/fixtures/repos.json'), status: 200,
      headers: {content_type: "application/json; charset=utf-8"}
    )
  end

  def stub_get(path, endpoint = Github.endpoint.to_s)
    stub_request(:get, endpoint + path)
  end

  test 'perform' do
    UserReposJob.perform_later(@user.id.to_s)
    assert_enqueued_jobs 1
  end

  test 'skip if already synced less than a hour back' do
    assert_nil @user.last_repo_sync_at
    @user.set(last_repo_sync_at: Time.now - 59.minutes)
    @user.expects(:fetch_all_github_repos).never
    UserReposJob.perform_now(@user.id.to_s)
  end

  test 'persist if unforked and popular' do
    User.any_instance.stubs(:fetch_all_github_repos).returns(
      JSON.parse(File.read('test/fixtures/unforked_repo.json'))
          .collect{|i| Hashie::Mash.new(i)}
    )
    assert_equal 0, Repository.count
    UserReposJob.perform_now(@user.id.to_s)
    assert_equal 1, Repository.count
    assert_equal Repository.first.owner, @user.github_handle
  end

  test 'Create source repo if forked' do
    User.any_instance.stubs(:fetch_all_github_repos).returns(
      JSON.parse(File.read('test/fixtures/repo.json'))
          .collect{|i| Hashie::Mash.new(i)}
    )
    assert_equal 0, Repository.count
    UserReposJob.perform_now(@user.id.to_s)
    assert_equal 1, Repository.count
    assert_not_equal Repository.first.owner, @user.github_handle
  end

  test 'destroy the repository if it is already persisted if the rating has dropped' do
    skip 'unscoped association not supported for soft deleted repo'
    repo = create :repository, name: 'code-curiosity', ssh_url: 'git@github.com:prasadsurase/code-curiosity.git',
      owner: 'prasadsurase', stars: 26, gh_id: 67219068
    @user.repositories << repo
    @user.save
    User.any_instance.stubs(:fetch_all_github_repos).returns(
      JSON.parse(File.read('test/fixtures/repos.json')).collect{|i| Hashie::Mash.new(i)}
    )
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(JSON.parse(File.read('test/fixtures/user-fork-repo.json')))
    )
    assert_nil repo.deleted_at
    assert_equal 1, Repository.count
    assert_equal 26, repo.stars
    UserReposJob.perform_now(@user.id.to_s)
    repo.reload
    refute_nil repo.deleted_at
    assert repo.destroyed?
    assert_equal 1, Repository.unscoped.count
    assert_equal 0, Repository.count
    assert_equal 24, repo.info.stargazers_count
    assert_equal 24, repo.stars
  end

  test 'restore the repository if it is already persisted and destroyed if the rating has increased' do
    skip 'unscoped association not supported for soft deleted repo'
    repo = create :repository, name: 'code-curiosity', ssh_url: 'git@github.com:prasadsurase/code-curiosity.git',
      owner: 'prasadsurase', stars: 24, gh_id: 67219068, deleted_at: Time.now - 2.days
    @user.repositories << repo
    @user.save
    User.any_instance.stubs(:fetch_all_github_repos).returns(
      JSON.parse(File.read('test/fixtures/repos.json')).collect{|i| Hashie::Mash.new(i)}
    )
    Repository.any_instance.stubs(:info).returns(
      Hashie::Mash.new(JSON.parse(File.read('test/fixtures/repo.json')))
    )
    refute_nil repo.deleted_at
    assert repo.destroyed?
    assert_equal 24, repo.stars
    assert_equal 0, Repository.count
    assert_equal 1, Repository.unscoped.count
    UserReposJob.perform_now(@user.id.to_s)
    repo.reload
    refute repo.destroyed?
    assert_nil repo.deleted_at
    assert_equal 1, Repository.unscoped.count
    assert_equal 1, Repository.count
    assert_equal 25, repo.info.stargazers_count
    assert_equal 25, repo.stars
  end

  describe 'set gh_repo_updated_at and gh_repo_created_at' do
    before do
      User.any_instance.stubs(:fetch_all_github_repos).returns(
        JSON.parse(File.read('test/fixtures/unforked_repo.json'))
            .collect{|i| Hashie::Mash.new(i)}
      )
    end

    test 'when repo is already present' do
      create :repository, gh_id: 67219068

      assert_equal 1, Repository.count
      UserReposJob.perform_now(@user.id.to_s)
      assert_equal 1, Repository.count
      assert_not_nil Repository.first.gh_repo_updated_at
    end

    test 'when new repo is created' do
      assert_equal 0, Repository.count
      UserReposJob.perform_now(@user.id.to_s)
      assert_equal 1, Repository.count
      assert_not_nil Repository.first.gh_repo_created_at
      assert_not_nil Repository.first.gh_repo_updated_at
    end
  end
end
