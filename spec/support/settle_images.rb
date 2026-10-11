# Browser specs with fake_images: true get a temporary route serving empty
# photos, removed after each example (paperclip.rb). A page can finish its
# assertions while photos are still downloading; a request that reaches the
# server after the route is gone fails the example with a RoutingError that
# has nothing to do with what it tests. Wait for in-flight photos first.
#
# This file loads after paperclip.rb, and RSpec runs `after` hooks in reverse
# order, so this runs before the route is removed. Lazy photos far off screen
# are never requested, so they are not waited for.
RSpec.configure do |config|
  config.after(:each, js: true, fake_images: true) do
    begin
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop do
          settled = page.evaluate_script(<<-JAVASCRIPT)
            Array.prototype.every.call(document.images, function(img) {
              if (img.complete) { return true; }
              var rect = img.getBoundingClientRect();
              return img.loading === 'lazy' && (rect.top > window.innerHeight + 3000 || rect.bottom < -3000);
            })
          JAVASCRIPT
          break if settled
          sleep 0.05
        end
      end
    rescue Timeout::Error, Selenium::WebDriver::Error::WebDriverError
      # Best effort: never fail an example from here.
    end
  end
end
