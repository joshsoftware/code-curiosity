class GitApp
  include Mongoid::Document
  GIT_INFO = YAML.load_file('config/git.yml')

  @@access_token_counter = 1

  def self.access_token_counter
    @@access_token_counter
  end

  def self.access_token_counter=(number)
    @@access_token_counter = number
  end

  def self.info
    access_token = GIT_INFO["access_token_#{access_token_counter}"]
    Github.new(
               oauth_token: access_token,
               client_id: ENV['GIT_APP_ID'],
               client_secret: ENV['GIT_APP_SECRET']
              )
  end

  def self.inc
    self.access_token_counter += 1
    self.access_token_counter = 1 if self.access_token_counter > GIT_INFO.count
  end
end
