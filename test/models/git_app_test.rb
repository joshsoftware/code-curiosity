require "test_helper"

class GitAppTest < ActiveSupport::TestCase
  def git_app
    @git_app ||= GitApp.new
  end

  def test_valid
    assert git_app.valid?
  end

  test 'inc function should increament app_credentials_counter' do
    assert_equal GitApp.app_credentials_counter, 1
    GitApp.inc
    assert_equal GitApp.app_credentials_counter, 2
  end

  test 'inc function should repeat counter from 1 after it reaches to 10' do
    GitApp.app_credentials_counter = 10
    GitApp.inc
    assert_equal GitApp.app_credentials_counter, 1
  end
end
