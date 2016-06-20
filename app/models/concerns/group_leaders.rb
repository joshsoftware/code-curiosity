module GroupLeaders

  def subscriotion_leaders(round)
    round.subscriptions
         .where(:user_id.in => member_ids, :points.gt => 0)
         .desc(:points)
         .limit(10)
  end
end
