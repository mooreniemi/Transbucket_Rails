#!/usr/bin/env ruby

require "capybara"
require "capybara/dsl"
require "selenium-webdriver"
require "json"

STAGING_URL = ENV.fetch("STAGING_URL", "https://transbucket-staging.herokuapp.com")
USERNAME = ENV.fetch("STAGING_USER", "zoon")
PASSWORD = ENV.fetch("STAGING_PASSWORD", "big fake password for testing")
IMAGE_PATH = File.expand_path("../spec/fixtures/cat.jpg", __dir__)

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--disable-gpu")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1800")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.default_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 20
Capybara.app_host = STAGING_URL
Capybara.run_server = false

class StagingSmoke
  include Capybara::DSL

  def run
    login
    pin_id = create_pin
    edit_pin(pin_id)
    puts "staging smoke ok pin=#{pin_id}"
  ensure
    Capybara.reset_sessions!
  end

  def login
    visit "/users/sign_in"
    within("#new_user") do
      fill_in "Username", with: USERNAME
      fill_in "Password", with: PASSWORD
    end
    click_button "Sign in"

    unless page.has_content?("Signed in successfully")
      raise "login failed"
    end
  end

  def create_pin
    visit "/pins/new"
    wait_for_dropzone

    upload_image("Smoke test image")

    suffix = Time.now.to_i
    add_surgeon(
      last_name: "Smoke#{suffix}",
      first_name: "User",
      url: "https://example.com/surgeons/#{suffix}"
    )
    add_procedure(
      name: "Smoke Procedure #{suffix}",
      body_type: "Top",
      gender: "FTM",
      description: nil
    )

    fill_in "Cost", with: "123"
    fill_details("Smoke test details")

    click_button "Submit Now"

    unless page.has_content?("Please respect pronouns")
      warn "create failed url=#{current_url}"
      if page.has_selector?("#error_explanation")
        warn page.find("#error_explanation").text
      end
      warn page.text[0, 800]
      raise "pin create failed"
    end

    current_url[%r{/pins/(\d+)}, 1] || raise("could not parse created pin id")
  end

  def edit_pin(pin_id)
    visit "/pins/#{pin_id}/edit"

    fill_in "Cost", with: "456"
    fill_details("Smoke test details updated")

    click_button "Submit Now"

    unless page.has_content?("Please respect pronouns")
      raise "pin edit failed"
    end

    unless page.has_content?("456")
      raise "updated cost missing"
    end
  end

  def wait_for_dropzone
    find(".dz-hidden-input", visible: false)
  end

  def upload_image(caption)
    page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")
    attach_file("dz-file-input", IMAGE_PATH, visible: false)

    unless page.has_selector?(".dz-image-preview img[alt]:not([alt=''])")
      raise "image preview did not appear"
    end

    preview = all(".dz-image-preview").last
    preview.fill_in("Caption", with: caption)
  end

  def add_surgeon(last_name:, first_name:, url:)
    find("#add_new_surgeon").click

    within("#surgeon_container") do
      fill_in "Surgeon's last name", with: last_name
      fill_in "Surgeon's first name", with: first_name
      fill_in "Surgeon's URL", with: url
    end
  end

  def add_procedure(name:, body_type:, gender:, description:)
    find("#add_new_procedure").click

    within("#procedure_container") do
      fill_in "Name of procedure", with: name
      select body_type, from: "pin_procedure_attributes_body_type"
      select gender, from: "pin_procedure_attributes_gender"
      fill_in "Describe this procedure", with: description if description
    end
  end

  def fill_details(text)
    page.execute_script("tinyMCE.activeEditor.setContent(#{text.inspect})")

    within_frame("pin_details_ifr") do
      unless page.has_text?(text)
        raise "details editor did not update"
      end
    end
  end

end

StagingSmoke.new.run
