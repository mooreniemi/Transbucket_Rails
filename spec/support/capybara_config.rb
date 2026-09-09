require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'

Capybara.server = :webrick

# The Docker image runs everything as root, and Chromium refuses to use its
# sandbox as root -- :selenium_chrome_headless doesn't pass --no-sandbox, so
# register a driver that does. disable-dev-shm-usage avoids /dev/shm running
# out of space in the container's default small shared-memory allocation.
Capybara.register_driver :selenium_chrome_headless_docker do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox disable-dev-shm-usage]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# remove _headless_docker to actually see it manipulate chrome (outside Docker)
Capybara.javascript_driver = :selenium_chrome_headless_docker
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
ActionMailer::Base.default_url_options[:host] = "localhost:#{Capybara.server_port}"

RSpec.configure do |config|
  config.before(:each, js: true) do
    # only for poltergeist?
    # page.driver.browser.url_blacklist = ["http://use.typekit.net", "http://www.google-analytics.com"]
  end
end
