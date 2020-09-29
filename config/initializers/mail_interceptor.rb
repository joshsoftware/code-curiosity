if Rails.env.development?
  require Rails.root.join("lib", "development_mail_interceptor.rb")
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
end
