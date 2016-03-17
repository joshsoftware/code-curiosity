require 'github_client'
require 'git_lib_ext'
require 'commits_fetcher'
require 'activities_fetcher'

GITHUB_URL = 'https://github.com'
GITHUB = Github.new(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])
GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])

WALLET_CONFIG = YAML.load_file('config/code_curiosity_config.yml')['wallet']
ROUND_CONFIG =  YAML.load_file('config/code_curiosity_config.yml')['round']
MESSAGE_LIST =  YAML.load_file('config/code_curiosity_config.yml')['messages']

STAR_RATINGS = (0..5).to_a
