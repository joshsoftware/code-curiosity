require "test_helper"

class GitAppTest < ActiveSupport::TestCase
  GIT_INFO = YAML.load_file('config/git.yml')
  
  def git_app
    @git_app ||= GitApp.new
  end

  def test_valid
    assert git_app.valid?
  end

  test 'inc function should increament access_token_counter' do
    assert_equal GitApp.access_token_counter, 1
    GitApp.inc
    assert_equal GitApp.access_token_counter, 2
  end

  test 'inc function should repeat counter from 1 after it reaches to GIT_INFO.count' do
    GitApp.access_token_counter = GIT_INFO.count
    GitApp.inc
    assert_equal GitApp.access_token_counter, 1
  end
end
