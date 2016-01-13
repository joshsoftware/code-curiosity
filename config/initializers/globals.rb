YAML.load_file("#{Rails.root}/config/git.yml")[Rails.env].each do |k,v|
  ENV[k] = v
end if File.exists?("#{Rails.root}/config/git.yml")

TOKEN = ENV['git_oauth_token']

GITHUB = Github.new oauth_token: TOKEN

