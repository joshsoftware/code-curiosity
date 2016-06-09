module GroupsHelper

  def owner?(member)
    @group.owner == member
  end
end
