class OrgReposJob < ActiveJob::Base
  queue_as :git

  attr_accessor :org

  def perform(org)
    @org = org
    @org.set(last_repo_sync_at: Time.now)

    GITHUB.repos(org: org.github_handle).list(per_page: 100).each_page do |repos|
      repos.each do |gh_repo|
        add_repo(gh_repo)
      end
    end
  end

  def add_repo(gh_repo)
    repo = Repository.where(gh_id: gh_repo.id).first

    if repo
      repo.set(organization_id: org.id)
      return
    end

    repo = Repository.build_from_gh_info(gh_repo)

    if repo.stars >= REPOSITORY_CONFIG['popular']['stars']
      repo.organization = org
      repo.save
      return
    end

    return unless gh_repo.fork
    return if repo.info.source.stargazers_count < REPOSITORY_CONFIG['popular']['stars']

    repo.popular_repository = repo.create_popular_repo
    repo.source_gh_id = repo.info.source.id
    repo.organization = org
    repo.save
  end

end
