# Preview all emails at http://localhost:3000/rails/mailers/redeem_mailer
class RedeemMailerPreview < ActionMailer::Preview

  def redeem_request
    RedeemMailer.redeem_request(RedeemRequest.first)
  end

  def notify_admin
    RedeemMailer.notify_admin(RedeemRequest.first)
  end

  def coupon_code
    request = RedeemRequest.where(:coupon_code.ne => nil).first || RedeemRequest.first
    RedeemMailer.coupon_code(request)
  end

end
