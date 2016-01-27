class SubscriptionMailer < ApplicationMailer

  def subscription_email(user)
    @user = user
    subject_message = "Welcome to #{Date.today.strftime("%B")} challenge round of Code Curiosity"
    mail(subject:"#{subject_message}")
  end

end
