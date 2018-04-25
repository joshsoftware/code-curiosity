module Admin::SubscriptionsHelper

  def total_subscription_amount
    SponsorerDetail.active.map do |subscription|
      SPONSOR["#{subscription.sponsorer_type.downcase}"]["base"]
    end.sum
  end

end
