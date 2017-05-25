class StripeController < ApplicationController

  protect_from_forgery :except => :webhooks

  def webhooks
    begin
    event_json = JSON.parse(request.body.read)
    event_object = event_json['data']['object']
    #refer event types here https://stripe.com/docs/api#event_types
    case event_json['type']
      when 'customer.subscription.created'
        subscriber = SponsorerDetail.find_by(customer_id: event.data.object.customer)
        subscriber.subscribed_at = Time.at(event.data.object.start).to_datetime
        subscriber.subscription_expires_at = Time.at(event.data.object.current_period_end).to_datetime
        subscriber.save
      when 'invoice.payment_succeeded'
        #send a mail regarding successfull payment and update expiry date
        handle_success_invoice event_object
      when 'invoice.payment_failed'
        #send a mail regarding unsuccessfull payment
        handle_failure_invoice event_object
      when 'customer.subscription.deleted'
        @sponsor = SponsorerDetail.find_by(customer.id)
        @sponsor.subscription_id = nil
        @sponsor.subscribed_at = nil
        @sponsor.subscription_expires_at = nil
        @sponsor.save
      when 'customer.subscription.updated'
    end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end

end
