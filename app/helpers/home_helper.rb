module HomeHelper

  def featured_groups
    @featured_groups =  Group.where(is_featured: true)
  end

  def featured_groups_size
    @size = @featured_groups.size
  end

  def sponsorer_organizations
    @sponsorer_organizations = SponsorerDetail.organizations.active.publish
    @sponsorer_users = SponsorerDetail.individuals.active.publish
  end

  def select_avatar(sponsorer)
    if sponsorer.avatar?
      sponsorer.avatar
    else
      avatar_url(sponsorer.user)
    end
  end

  def redirect(sponsorer)
    if sponsorer.organization_url?
      sponsorer.organization_url
    else
      user_path(sponsorer.user.github_handle.downcase)
    end
  end

  def widget_class
    if @size > 2
      "col-md-4"
    elsif @size == 2
      "col-md-6"
    else
      "col-md-12"
    end
  end

  def multi_line_chart

    users = Subscription.collection.aggregate( [  { "$group" => { _id: "$round_id", total: { "$sum" => 1 } } } ] ).sort {|x, y| Date.parse(Round.find(y["_id"]).name) <=> Date.parse(Round.find(x["_id"]).name) }.collect { |r| [ Round.find(r["_id"]).name, r["total"] ] }
    users = users[1..6].reverse if users.any?


    contributions = Subscription.collection.aggregate( [ {"$match" => { "created_at" => { "$gt" => Date.parse("march 2016") } } }, { "$group" => { _id: "$round_id", total: { "$sum" => "$points" } } } ]).sort {|x, y| Date.parse(Round.find(y["_id"]).name) <=> Date.parse(Round.find(x["_id"]).name) }.collect { |r| [ Round.find(r["_id"]).name, r["total"] ] }
    contributions = contributions[1..6].reverse if contributions.any?

    @user_trend = []
    @contribution_trend = []
    @user_xAxis = []
    @xAxis = []

    users.map{ |user| @user_trend << user[1]; @user_xAxis << user[0]}

    contributions.map{ |contribution| @contribution_trend << contribution[1]; @xAxis << contribution[0]}


 end

end
