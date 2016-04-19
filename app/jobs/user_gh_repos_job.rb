class UserGhReposJob < ActiveJob::Base
  queue_as :git

  attr_accessor :user, :type

  rescue_from(StandardError) do |exception|
    if user
      user.set(last_repo_sync_at: nil) if type == 'user'
      user.set(last_org_repo_sync_at: nil) if type == 'org'
    end
  end

  def perform(user, type)
    @user = user
    @type = type

    if type == 'user'
      fetch_users_repos
    else
      fetch_orgs_repos
    end
  end

  def fetch_users_repos
    user_repos = fetch_repos(GITHUB.repos(user: user.github_handle))
    Rails.cache.write("repos/#{user.id}", user_repos.to_json, expires_in: 1.month)
  end

  def fetch_orgs_repos
    GITHUB.orgs(user: user.github_handle).list.each_page do |orgs|
      orgs.each do |org|
        repos = fetch_repos(GITHUB.repos(org: org.login))

        if repos.any?
          Rails.cache.write("repos/org/#{org.login}", repos.to_json, expires_in: 1.month)
        end
      end
    end
  end

  def fetch_repos(gh_query)
    matched_repos = []

    gh_query.list(per_page: 100).each_page do |repos|
      repos.each do |repo|
        matched_repos << repo if can_contribute?(repo)
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
