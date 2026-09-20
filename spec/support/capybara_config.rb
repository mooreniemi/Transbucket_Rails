require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'

Capybara.server = :webrick

# The Docker image runs everything as root, and Chromium refuses to use its
# sandbox as root -- :selenium_chrome_headless doesn't pass --no-sandbox, so
# register a driver that does. disable-dev-shm-usage avoids /dev/shm running
# out of space in the container's default small shared-memory allocation.
# window-size pins a desktop viewport: headless Chrome's default can land just
# under the site's 768px breakpoint, which switches the surgeon/procedure fields
# to the touch pickers and hides the Chosen widgets these specs drive.
Capybara.register_driver :selenium_chrome_headless_docker do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox disable-dev-shm-usage window-size=1400,1000]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# remove _headless_docker to actually see it manipulate chrome (outside Docker)
Capybara.javascript_driver = :selenium_chrome_headless_docker
# Let Capybara choose an available port for each server. In Capybara 3.35, a
# literal zero is passed through to WEBrick instead of being resolved first.
Capybara.server_port = nil
ActionMailer::Base.default_url_options[:host] = 'localhost'

RSpec.configure do |config|
  config.before(:each, js: true) do
    # only for poltergeist?
    # page.driver.browser.url_blacklist = ["http://use.typekit.net", "http://www.google-analytics.com"]
  end
end
