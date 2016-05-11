require 'github_client'
require 'git_lib_ext'

GITHUB = Github.new(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])
GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])

YAML.load_file('config/code_curiosity_config.yml').tap do |config|
  ROUND_CONFIG =  config['round']
  REPOSITORY_CONFIG = config['repository']
  SCORING_ENGINE_CONFIG = config['scoring_engine']
  USER = config['user']
end

USER_GROUPS = YAML.load_file('config/user_group.yml')['groups']
COMMIT_RATINGS = (0..5).to_a
ACTIVITY_RATINGS = (0..2).to_a

INFO = YAML.load_file('config/info.yml')
