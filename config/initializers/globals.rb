require 'github_client'
require 'git_lib_ext'

GITHUB = Github.new(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])
GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])

YAML.load_file('config/code_curiosity_config.yml').tap do |config|
  REPOSITORY_CONFIG = config['repository']
  SCORING_ENGINE_CONFIG = config['scoring_engine']
  REDEEM = config['redeem']
  REDEEM_THRESHOLD = config['redeem_request_threshold']
  ACCOUNT = config['account']
  ORGANIZATIONAL_SPONSORERS = config['organizational_sponsorers']
  TRANSACTION = config['transaction']
end

COMMIT_RATINGS = (0..5).to_a
ACTIVITY_RATINGS = (0..2).to_a

INFO = YAML.load_file('config/info.yml')
BADGE = YAML.load_file('config/badge.yml')

MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

NEW_FEATURE_LAUNCH_DATE = Date.new(2018,7,1)
