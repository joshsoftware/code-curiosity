GITHUB = Github.new oauth_token: ENV['GIT_OAUTH_TOKEN']
WALLET_CONFIG = YAML.load_file('config/code_curiosity_config.yml')['wallet']
ROUND_CONFIG =  YAML.load_file('config/code_curiosity_config.yml')['round']
MESSAGE_LIST =  YAML.load_file('config/code_curiosity_config.yml')['messages']
