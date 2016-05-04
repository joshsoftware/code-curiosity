class OrgReposJob < ActiveJob::Base
  queue_as :git

  def perform(org)
    org.set(last_repo_sync_at: Time.now)

    GITHUB.repos(org: org.github_handle).list(per_page: 100).each_page do |repos|
      repos.each do |gh_repo|
        add_repo(org, gh_repo)
      end
    end
  end

  def add_repo(org, gh_repo)
    repo = Repository.where(gh_id: gh_repo.id).first
    repo = Repository.build_from_gh_info(gh_repo) unless repo
    repo.organization = org
    repo.save(validate: false)
  end

end
