require "#{Rails.root.join("config/initializers/local_env")}" if Rails.env.development?
ORG_TEAM_ID = ENV['org_team_id']
TOKEN = ENV['git_oauth_token']

GITHUB = Github.new oauth_token: TOKEN
