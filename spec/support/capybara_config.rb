require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
ActionMailer::Base.default_url_options[:host] = "localhost:#{Capybara.server_port}"

RSpec.configure do |config|
  config.before(:each, js: true) do
    page.driver.browser.url_blacklist = ["http://use.typekit.net", "http://www.google-analytics.com"]
  end
end
