require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'

Capybara.server = :webrick
# remove _headless to actually see it manipulate chrome
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
ActionMailer::Base.default_url_options[:host] = "localhost:#{Capybara.server_port}"

RSpec.configure do |config|
  config.before(:each, js: true) do
    # only for poltergeist?
    # page.driver.browser.url_blacklist = ["http://use.typekit.net", "http://www.google-analytics.com"]
  end
end
