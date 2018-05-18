require 'github_client'
require 'git_lib_ext'

class GitApp
  include Mongoid::Document

  @@app_num = 1

  def self.app_num
    @@app_num
  end

  def self.app_num=(num)
    app_num = num
  end

  def self.info
    info = GIT_INFO['App_' + app_num.to_s]
    Github.new(
               oauth_token: info['access_tokens'],
               client_id: info['git_app_id'],
               client_secret: info['git_app_secret']
              )
  end

  def self.inc
    app_num += 1
    app_num = 1 if app_num > 10
  end
end
