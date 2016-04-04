require 'github_client'
require 'git_lib_ext'

GITHUB = Github.new(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])
GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])

YAML.load_file('config/code_curiosity_config.yml').tap do |config|
  ROUND_CONFIG =  config['round']
  REPOSITORY_CONFIG = config['repository']
  SCORING_ENGINE_CONFIG = config['scoring_engine']
end

STAR_RATINGS = (0..5).to_a
