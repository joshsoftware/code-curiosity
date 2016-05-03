require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  def organization
    @organization ||= Organization.new
  end

  def test_valid
    assert organization.valid?
  end
end
