module GhCacheHelper

  private

  def cache_user_repos(page)
    Rails.cache.fetch("#{current_user.github_handle}/repos/#{page}", expires_in: 1.hour) do
      GITHUB.repositories.list({
        user: current_user.github_handle,
        page: page,
        sort: 'updated',
        direction: 'desc'
      })
    end
  end

  def cache_org_repos(name, page)
    return [] if name.blank?

    Rails.cache.fetch("#{name}/repos/#{page}", expires_in: 1.hour) do
      GITHUB.repositories.list({
        org: name,
        page: page,
        sort: 'updated',
        direction: 'desc'
      })
    end
  end

end
