class SubscriptionMailer < ApplicationMailer

  def subscription_email(user)
    @user = user
    subject_message = "Welcome to #{Date.today.strftime("%B")} challenge round of Code Curiosity"
    mail(subject:"#{subject_message}")
  end

  def progress(user, round)
    @user = user
    @subscription = user.subscriptions.where(round: round).first

    message = if @subscription.goal_achived?
                "You have achived your goal before time."
              else
                "You have still time to achive your goal. Keep it up..."
              end

    mail(to: user.email, subject: "[CODECURIOSITY] #{message}")
  end

  def redeem_points(user, message)
    @user = user
    @message = message

    mail(to: user.email, subject: "[CODECURIOSITY] Your points for the month of #{Date.today.strftime("%B")}!")
  end

end
