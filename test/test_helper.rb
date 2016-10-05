require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'


ENV["RAILS_ENV"] = "test"

SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/rails/capybara"
require "capybara/poltergeist"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
 require "minitest/pride"

class ActionController::TestCase 
  include Devise::TestHelpers 
  include Warden::Test::Helpers 
end

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include FactoryGirl::Syntax::Methods 
  DatabaseCleaner.strategy = :truncation
  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }  
end

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  Capybara.current_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 1.minute, phantomjs_options: ['--load-images=no'])
  end
end