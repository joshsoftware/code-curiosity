class SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :round_date, :commits_count, :activities_count, :points

  def round_date
    object.round.from_date.strftime("%b %Y")
  end
end
