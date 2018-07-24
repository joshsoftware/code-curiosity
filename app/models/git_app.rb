class GitApp
  include Mongoid::Document
  
  @@access_token = nil

  def self.access_token
    @@access_token
  end

  def self.info
    update_token if @@access_token.nil?
    Github.new(
               oauth_token: @@access_token,
               client_id: ENV['GIT_APP_ID'],
               client_secret: ENV['GIT_APP_SECRET']
              )
  end

  def self.update_token
    user = User.where(:auth_token.ne => nil).all.sample
    @@access_token = User.encrypter.decrypt_and_verify(user.auth_token)
  end
end
