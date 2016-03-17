require 'development_mail_interceptor'

ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
