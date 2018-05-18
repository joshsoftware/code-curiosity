require 'github_client'
require 'git_lib_ext'

GITHUB = Github.new(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])
GithubClient.init(oauth_token: ENV['GIT_OAUTH_TOKEN'], client_id: ENV['GIT_APP_ID'], client_secret: ENV['GIT_APP_SECRET'])

YAML.load_file('config/code_curiosity_config.yml').tap do |config|
  ROUND_CONFIG =  config['round']
  REPOSITORY_CONFIG = config['repository']
  SCORING_ENGINE_CONFIG = config['scoring_engine']
  USER = config['user']
  REDEEM = config['redeem']
  SPONSOR = config['sponsor']
  SUBSCRIPTIONS = config['subscriptions']
  SPONSORER_THRESHOLD = config['sponsor_display_threshold']
  REDEEM_THRESHOLD = config['redeem_request_threshold']
  ACCOUNT = config['account']
  ORGANIZATIONAL_SPONSORERS = config['organizational_sponsorers']
end

COMMIT_RATINGS = (0..5).to_a
ACTIVITY_RATINGS = (0..2).to_a
GIT_INFO = YAML.load_file('config/git.yml')

INFO = YAML.load_file('config/info.yml')

MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
