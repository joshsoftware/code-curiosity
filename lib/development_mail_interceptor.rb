class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = "testvx100@gmail.com"
    Rails.logger.debug "Interceptor prevented sending mail #{message.inspect}!"
  end
end
