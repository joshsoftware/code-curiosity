namespace :newsletter do
  desc "Send a general newsletter to all CodeCuriosity user"
  task :general, [:subject, :template_name] => :environment do |t, args|
    args.with_defaults(subject: "General Newsletter", template_name: "general")
    users = User.contestants

    users.each do |user|
      NewsletterMailer.general(args.subject, args.template_name, user.id.to_s).deliver_later
    end
  end
end
