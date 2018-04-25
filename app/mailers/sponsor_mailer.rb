class SponsorMailer < ApplicationMailer
  def subscription_payment_failed(user, message)
    @user = User.find(id: user)
    @message = message
    mail(to: @user.email, subject: "Payment to CodeCuriosity failed")
  end

  def notify_subscriber(user_id, plan, amount)
    @user = User.find(id: user_id)
    @plan = plan
    @amount = amount
    mail(to: @user.email, subject: "Details of subscription as sponsor to CodeCuriosity")
  end

  def notify_admin(user_id, plan, amount)
    @user = User.find(id: user_id)
    @plan = plan
    @amount = amount
    mail(to: ENV['ADMIN_EMAILS'].split(','), subject: "New subscription for #{@user.name}")
  end
end
