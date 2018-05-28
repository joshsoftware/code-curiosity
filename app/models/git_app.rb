class GitApp
  include Mongoid::Document

  @@app_credentials_counter = 1

  def self.app_credentials_counter
    @@app_credentials_counter
  end

  def self.app_credentials_counter=(number)
    @@app_credentials_counter = number
  end

  def self.info
    info = GIT_INFO["App_#{app_credentials_counter}"]
    Github.new(
               oauth_token: info['access_tokens'],
               client_id: info['git_app_id'],
               client_secret: info['git_app_secret']
              )
  end

  def self.inc
    self.app_credentials_counter += 1
    self.app_credentials_counter = 1 if self.app_credentials_counter > 10
  end
end
