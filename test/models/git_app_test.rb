require "test_helper"

class GitAppTest < ActiveSupport::TestCase
  def git_app
    @git_app ||= GitApp.new
  end

  def test_valid
    assert git_app.valid?
  end
end
