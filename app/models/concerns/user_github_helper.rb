module UserGithubHelper
  def gh_auth_token
    User.encrypter.decrypt_and_verify(auth_token)
  end

  def gh_client
    @gh_client ||= Github.new({
      oauth_token: auth_token.present? ? gh_auth_token : ENV['GIT_OAUTH_TOKEN'],
      client_id: ENV['GIT_APP_ID'],
      client_secret: ENV['GIT_APP_SECRET']
    })
  end

  # In case we get a Github::Error::Unauthorized, we cannot use the user token.
  # Here, we use any other users random token and the next time user logs in,
  # it will refresh the user auth_token and start working normally
  # This also helps us manage the Github API limits
  def refresh_gh_client
    u = User.where(:auth_token.ne => nil).all.sample
    auth_tk = User.encrypter.decrypt_and_verify(u.auth_token)
    @gh_client = Github.new({
      oauth_token: auth_tk,
      client_id: ENV['GIT_APP_ID'],
      client_secret: ENV['GIT_APP_SECRET']
    })
  end

  def fetch_all_github_repos
    all_repos = []
    gh_client.repos.list(per_page: 100).each_page do |repos|
      repos.each{|r| all_repos << r }
      # hashie warning on concat
      # all_repos.concat(repos)
    end

    all_repos
  end

  def gh_orgs
    @gh_orgs ||= gh_client.organizations.all(user: github_handle)
  end

  def info
    @info ||= gh_client.users.get(user: github_handle)
  end
end
