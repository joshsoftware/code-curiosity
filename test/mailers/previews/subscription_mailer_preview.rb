# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
class SubscriptionMailerPreview < ActionMailer::Preview

  def progress
    user = User.contestants.first
    SubscriptionMailer.progress(user, Round.opened)
  end
end
