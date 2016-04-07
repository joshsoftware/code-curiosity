class UserGhReposJob < ActiveJob::Base
  queue_as :git

  attr_accessor :user, :repos_star_count

  #rescue_from(StandardError) do |exception|
  #  user.set(gh_sync_job: nil) if user
  #end

  def perform(user, type = 'user')
    @user = user

    if type == 'user'
      fetch_users_repos
    else
      fetch_orgs_repos
    end

    user.gh_sync_jobs[type] = nil
    user.save
  end

  def fetch_users_repos
    self.repos_star_count = 0

    user_repos = fetch_repos(GITHUB.repos(user: user.github_handle, per_page: 100))
    Rails.cache.write("repos/#{user.id}", user_repos.to_json)
    user.set(repos_star_count: repos_star_count)
  end

  def fetch_orgs_repos
    GITHUB.orgs(user: user.github_handle, per_page: 100).list.each_page do |orgs|
      orgs.each do |org|
        repos = fetch_repos(GITHUB.repos(org: org.login))

        if repos.any?
          Rails.cache.write("repos/org/#{org.login}", repos.to_json)
        end
      end
    end
  end

  def fetch_repos(gh_query)
    matched_repos = []

    gh_query.list.each_page do |repos|
      repos.each do |repo|
        matched_repos << repo if can_contribute?(repo)
        self.repos_star_count += repo.stargazers_count if gh_query.org.nil?
      end
    end

    return matched_repos
  end

  def can_contribute?(repo)
    return true if repo.stargazers_count >= REPOSITORY_CONFIG['popular']['stars']

    if repo.fork
      full_repo_info = GITHUB.repositories.get(*repo.full_name.split('/'))

      return true if full_repo_info.source.stargazers_count >= REPOSITORY_CONFIG['popular']['stars']
    end

    return false
  end
end
