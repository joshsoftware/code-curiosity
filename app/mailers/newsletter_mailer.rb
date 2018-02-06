class NewsletterMailer < ApplicationMailer
  default from: "info@codecuriosity.org"

  def general(subject, template_name, user_id)
    @user = User.find_by(id: user_id)
    attachments.inline['tweet.png'] = File.read("#{Rails.root}/public/gautam-tweet.png")

    mail(to: @user.email, subject: "[CODECURIOSITY] #{subject}",
      template_name: template_name)
  end
end
