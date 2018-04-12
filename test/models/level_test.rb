require "test_helper"

class LevelTest < ActiveSupport::TestCase
  def level
    @level ||= Level.new
  end

end
