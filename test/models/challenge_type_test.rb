require "test_helper"

class ChallengeTypeTest < ActiveSupport::TestCase
  def challenge_type
    @challenge_type ||= ChallengeType.new
  end

end
