class StripeController < ApplicationController
  require "stripe"
  protect_from_forgery :except => :webhooks

  def webhooks
    begin
    event_json = JSON.parse(request.body.read)
    event_object = event_json['data']['object']
    #refer event types here https://stripe.com/docs/api#event_types
    case event_json['type']
      when 'customer.subscription.created'
        subscriber = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
        subscriber.subscribed_at = Time.at(event_object['start']).to_datetime
        subscriber.subscription_expires_at = Time.at(event_object['current_period_end']).to_datetime
        subscriber.subscription_status = event_object['status']
        subscriber.save
      when 'invoice.payment_succeeded'
        #send a mail regarding successfull payment and update expiry date
        subscriber = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
        subscriber.subscription_expires_at = Time.at(event_object['current_period_end']).to_datetime
        subscriber.save
      when 'invoice.payment_failed'
        #send a mail regarding unsuccessfull payment
        if event_object['attempt_count'] == 1
          charge = Stripe::Charge.retrieve(event_object['charge'])
          message = charge.failure_message
          user_id = SponsorerDetail.find_by(stripe_customer_id: event_object['customer']).user_id
          SponsorMailer.subscription_payment_failed(user_id.to_s, message).deliver_later
        end
      when 'customer.subscription.updated'
        subscriber = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
        subscriber.subscription_status = event_object['status']
        subscriber.save
      when 'customer.source.created'
        subscriber = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
        if subscriber.subscription_status == 'unpaid'
          latest_invoice = Stripe::Invoice.list(:customer => subscriber.stripe_customer_id).data.first
          invoice.update(closed: false)
          invoice.pay
        end
      when 'customer.subscription.deleted'
        @sponsor = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
        @sponsor.subscription_status = event_object['status']
        @sponsor.save
    end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end

end
