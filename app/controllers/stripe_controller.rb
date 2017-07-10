class StripeController < ApplicationController
  require "stripe"
  protect_from_forgery :except => :webhooks

  def webhooks
    begin
      event_json = JSON.parse(request.body.read)
      event_object = event_json['data']['object']
      subscriber = SponsorerDetail.find_by(stripe_customer_id: event_object['customer'])
      #refer event types here https://stripe.com/docs/api#event_types
      case event_json['type']
        when 'customer.subscription.created'
          handle_subscription_created_event(subscriber, event_object)
        when 'invoice.payment_succeeded'
          handle_payment_succeded_event(subscriber, event_object)
        when 'invoice.payment_failed'
          handle_payment_failed_event(subscriber, event_object)
        when 'customer.subscription.updated'
          update_subscription_status(subscriber, event_object)
        when 'customer.source.created'
          handle_source_created_event(subscriber, event_object)
        when 'customer.subscription.deleted'
          update_subscription_status(subscriber, event_object)
      end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end

  def handle_subscription_created_event(subscriber, event_object)
    subscriber.subscribed_at = Time.at(event_object['start']).to_datetime
    subscriber.subscription_expires_at = Time.at(event_object['current_period_end']).to_datetime
    subscriber.subscription_status = event_object['status']
    subscriber.save
  end

  def handle_payment_succeded_event(subscriber, event_object)
    #send a mail regarding successfull payment, update expiry date
    subscriber.subscription_expires_at = Time.at(event_object['lines']['data'].first['period']['end']).to_datetime
    plan = event_object['lines']['data'].first['plan']['name']
    subscriber.save_payment_details(plan, event_object['amount_due'], event_object['date'])
    subscriber.save
  end

  def handle_payment_failed_event(subscriber, event_object)
    #send a mail regarding unsuccessfull payment
    if event_object['attempt_count'] == 1
      charge = Stripe::Charge.retrieve(event_object['charge'])
      message = charge.failure_message
      user_id = SponsorerDetail.find_by(stripe_customer_id: event_object['customer']).user_id
      SponsorMailer.subscription_payment_failed(user_id.to_s, message).deliver_later
    end
  end

  def handle_source_created_event(subscriber, event_object)
    #reopen the latest invoice and pay
    if subscriber.subscription_status == 'unpaid'
      latest_invoice = Stripe::Invoice.list(:customer => subscriber.stripe_customer_id).data.first
      invoice.update(closed: false)
      invoice.pay
    end
  end

  def update_subscription_status(subscriber, event_object)
    subscriber.subscription_status = event_object['status']
    subscriber.save
  end
end
