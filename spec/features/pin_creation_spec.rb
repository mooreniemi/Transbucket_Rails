require 'rails_helper'
require 'faker'

describe "pin creation" do
  let(:user) { create(:user, :with_confirmation) }
  let!(:surgeon) { create(:surgeon) }
  let!(:procedure) { create(:procedure) }

  before :each do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  it "should create a new pin with data and images", :js => true do
    visit '/pins/new'

    find(".dz-hidden-input", visible: false)
    page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")

    attach_file("dz-file-input", Rails.root.join("spec", "fixtures", "cat.jpg"), visible: false)

    cat_img = find('.dz-preview img[alt]:not([alt=""])')

    expect(cat_img[:alt]).to eql("cat.jpg")

    caption = "je suis le chat"
    within("#dropper") do
      fill_in "Caption", :with => caption
    end

    expect(page).to have_no_selector("#submit-all[disabled]")

    click_button "Upload photos"

    expect(find("#dropper")).to have_selector(".dz-complete")
    save_screenshot("/Users/corajr/Desktop/uploaded.png")

    pin_data = { :cost => rand(999),
                 :experience => Faker::Lorem.sentences(3).join(" ")
               }

    within("#new_pin") do
      fill_in "Cost", :with => pin_data[:cost]
    end

    page.execute_script("tinyMCE.activeEditor.setContent('#{pin_data[:experience]}')")

    click_button "Submit Now"

    expect(page).to have_content("Pin was successfully created.")

    thumbnail = find(".thumbnail")
    expect(thumbnail.find(".caption").text).to eql(caption)

    expect(find('dl')).to have_content(pin_data[:cost])

    experience_section = find("#details")
    expect(experience_section).to have_content(pin_data[:experience])
  end
end
