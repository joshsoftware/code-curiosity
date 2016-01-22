
GITHUB = Github.new oauth_token: ENV['GIT_OAUTH_TOKEN']

WALLET_CONFIG = YAML.load_file('config/wallet.yml')
