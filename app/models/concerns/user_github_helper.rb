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

  def fetch_all_github_repos
    all_repos = []
    gh_client.repos.list(per_page: 100).each_page do |repos|
      repos.each{|r| all_repos << r }
      # hashie warning on concat
      # all_repos.concat(repos)
    end

    all_repos
  end
end
