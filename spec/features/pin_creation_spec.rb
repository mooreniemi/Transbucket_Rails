require 'rails_helper'
require 'faker'

describe "pin creation" do
  include CapybaraHelpers

  let(:user) { create(:user, :with_confirmation) }
  let(:new_images) { build_list(:pin_image, 3) }

  before :each do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  def pin_create(&block)
    visit '/pins/new'

    pin_data = gen_pin_data

    add_images(new_images)
    enter_details(pin_data)

    click_button "Submit Now"
    block.call(pin_data)
  end

  def pin_create_js(&block)
    visit '/pins/new'

    pin_data = gen_pin_data

    add_images(new_images, js: true)

    expect(page).to have_no_selector("#submit-all[disabled]")

    enter_details(pin_data, js: true)

    click_button "Submit Now"
    block.call(pin_data)
  end

  shared_examples "the pin creation process" do |pin_creator|
    context "with no surgeons or procedures" do
      it "should fail to create a new pin, displaying errors" do
        self.send(pin_creator) do |pin_data|
          expect(page).to have_content("Surgeon can't be blank")
          expect(page).to have_content("Procedure can't be blank")
        end
      end
    end
    context "with surgeon and procedure initialized" do
      let!(:surgeon) { create(:surgeon) }
      let!(:procedure) { create(:procedure) }

      it "should create a new pin with data and images" do
        self.send(pin_creator) do |pin_data|
          expect(page).to have_content("Please respect pronouns")

          check_pin_data(pin_data)
          check_photos(new_images)
        end
      end
    end
  end

  context "with no js" do
    include_examples "the pin creation process", :pin_create
  end

  context "with js", :js => true do
    include_examples "the pin creation process", :pin_create_js
  end
end
