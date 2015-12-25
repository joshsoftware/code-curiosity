require "#{Rails.root.join("config/initializers/local_env")}" if Rails.env.development?
TOKEN = ENV['git_oauth_token']

GITHUB = Github.new oauth_token: TOKEN
