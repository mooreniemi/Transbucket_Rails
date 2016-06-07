require 'rails_helper'
require 'faker'

describe "pin creation" do
  let(:user) { create(:user, :with_confirmation) }
  let(:caption) { "je suis le chat" }

  before :each do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  # TODO should it be possible to create pins without JS?
  def pin_create_js(&block)
    visit '/pins/new'

    find(".dz-hidden-input", visible: false)
    page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")

    attach_file("dz-file-input", Rails.root.join("spec", "fixtures", "cat.jpg"), visible: false)

    cat_img = find('.dz-preview img[alt]:not([alt=""])')
    expect(cat_img[:alt]).to eql("cat.jpg")

    find("#dropper").fill_in("Caption", :with => caption)

    expect(page).to have_no_selector("#submit-all[disabled]")
    click_button "Upload photos"

    expect(find("#dropper")).to have_selector(".dz-complete")

    pin_data = { :cost => rand(999),
                 :experience => Faker::Lorem.sentences(3).join(" ")
               }

    within("#new_pin") do
      fill_in "Cost", :with => pin_data[:cost]
    end

    page.execute_script("tinyMCE.activeEditor.setContent('#{pin_data[:experience]}')")

    click_button "Submit Now"
    block.call(pin_data)
  end

  context "with no surgeons or procedures", :js => true do
    it "should fail to create a new pin, redirecting to edit page with errors" do
      pin_create_js do |pin_data|
        expect(page).to have_content("Surgeon can't be blank")
        expect(page).to have_content("Procedure can't be blank")
      end
    end
  end

  context "with surgeon and procedure initialized", :js => true do
    let!(:surgeon) { create(:surgeon) }
    let!(:procedure) { create(:procedure) }

    it "should create a new pin with data and images" do
      pin_create_js do |pin_data|
        expect(page).to have_content("Pin was successfully created.")

        thumbnail = find(".thumbnail")
        expect(thumbnail.find(".caption").text).to eql(caption)

        expect(find('dl')).to have_content(pin_data[:cost])

        experience_section = find("#details")
        expect(experience_section).to have_content(pin_data[:experience])
      end
    end
  end
end
