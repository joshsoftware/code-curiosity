class UserReposJob < ActiveJob::Base
  queue_as :git

  attr_accessor :user

  rescue_from(StandardError) do |exception|
    user.set(last_repo_sync_at: nil) if user
  end

  def perform(user)
    @user = user

    user.set(last_repo_sync_at: Time.now)
    gh_repos = user.fetch_all_github_repos

    gh_repos.each do |gh_repo|
      add_repo(gh_repo)
    end
  end

  def add_repo(gh_repo)
    repo = Repository.where(gh_id: gh_repo.id).first

    if repo
      repo.users << user unless repo.users.include?(user)
      return
    end

    repo = Repository.build_from_gh_info(gh_repo)

    if repo.stars >= REPOSITORY_CONFIG['popular']['stars']
      user.repositories << repo
      user.save
      return
    end

    return unless gh_repo.fork

    if process_fork_repo(repo)
      user.repositories << repo
      user.save
    end
  end

  def process_fork_repo(repo)
    org_repo = Repository.where(:organization_id.ne => nil, gh_id: repo.info.source.id).first
    repo.source_gh_id = repo.info.source.id

    if org_repo
      repo.organization_id = org_repo.organization_id
    end

    if repo.info.source.stargazers_count >= REPOSITORY_CONFIG['popular']['stars']
      repo.popular_repository = create_popular_repo(repo.info.source)
    end

    return repo.organization_id || repo.popular_repository
  end

  def create_popular_repo(gh_repo)
    repo = Repository.where(gh_id: gh_repo.id).first
    return repo if repo

    repo = Repository.build_from_gh_info(gh_repo)
    repo.type = 'popular'
    repo.save
    Repository.create_repo_owner_account(gh_repo)

    return repo
  end
end
