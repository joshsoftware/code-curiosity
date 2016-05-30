class RedeemMailer < ApplicationMailer
   default from: 'noreplay@codecuriosity.org"'

  def redeem_request(request)
    @user = request.user
    @points = request.points

    mail(to: @user.email, subject: "#{@points} points redeem request")
  end
end
