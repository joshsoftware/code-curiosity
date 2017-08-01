class StripeController < ApplicationController
  protect_from_forgery except: :webhooks

  def webhooks
    begin
      handler = StripeResponseHandler.new(request)
      handler.handle
    rescue Exception => ex
      render json: { status: 422, error: "Webhook call failed" }
      return
    end
    render json: { status: 200 }
  end

end
