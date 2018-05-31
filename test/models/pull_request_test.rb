require "test_helper"

class PullRequestTest < ActiveSupport::TestCase
  def pull_request
    @pull_request ||= PullRequest.new
  end

  def test_valid
    assert pull_request.valid?
  end
end
