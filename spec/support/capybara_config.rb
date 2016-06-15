RSpec.configure do |config|
  config.before(:each, js: true) do
    page.driver.browser.url_blacklist = ["http://use.typekit.net", "http://www.google-analytics.com"]
  end
end
