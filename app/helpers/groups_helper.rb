module GroupsHelper

  def group_owner?(member)
    @group.owner == member
  end
end
