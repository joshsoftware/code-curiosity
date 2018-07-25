require "test_helper"

class GitAppTest < ActiveSupport::TestCase
  GIT_INFO = YAML.load_file('config/git.yml')
  
  def setup
    @user =  create :user, name: 'user'
  end

  def git_app
    @git_app ||= GitApp.new
  end

  def test_valid
    assert git_app.valid?
  end

  test 'info method should update access_token when it is nil' do
    @user.auth_token = User.encrypter.encrypt_and_sign('631375614b9ea46165cf63ae7ee522291e912592')
    @user.save
    GitApp.info
    assert_equal GitApp.access_token, '631375614b9ea46165cf63ae7ee522291e912592'
  end

  test 'update token method should update access_token whenever called' do
    @user.auth_token = User.encrypter.encrypt_and_sign('5d96b0c2abd3c8a850960a40a9703113ce0218f2')
    @user.save
    GitApp.update_token
    assert_equal GitApp.access_token, '5d96b0c2abd3c8a850960a40a9703113ce0218f2'
  end
end
