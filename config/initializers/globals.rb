require 'github_client'

GITHUB = Github.new oauth_token: ENV['GIT_OAUTH_TOKEN']

GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'])

