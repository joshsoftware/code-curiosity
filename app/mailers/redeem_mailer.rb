class RedeemMailer < ApplicationMailer
  default from: 'noreplay@codecuriosity.org'

  def redeem_request(request)
    @user = request.user
    @points = request.points

    mail(to: @user.email, subject: "[CODECURIOSITY] #{@points} points redeem request")
  end

  def notify_admin(request)
    @redeem_request = request
    @user = request.user

    mail(to: ENV['ADMIN_EMAILS'].split(','), subject: "Redeem Request from #{request.user.github_handle}")
  end

  def coupon_code(request)
    @user = request.user
    @redeem_request = request

    mail(to: request.user.email, subject: "[CODECURIOSITY] Here is your gift...")
  end
end
