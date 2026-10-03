# Every browser (js: true) example starts at the desktop size the driver is
# registered with (capybara_config.rb). Some specs shrink the window to phone
# width to check mobile layouts; without this, whichever spec random ordering
# ran next inherited that width, and below 768px the pin form swaps its Chosen
# dropdowns for touch pickers, so pin_creation_spec failed for no reason of its
# own ("Unable to find css #pin_surgeon_attributes_id_chosen").
RSpec.configure do |config|
  config.before(:each, js: true) do
    page.current_window.resize_to(1400, 1000)
  end
end
