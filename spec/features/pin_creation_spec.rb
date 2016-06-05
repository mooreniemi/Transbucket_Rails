require 'rails_helper'

describe "pin creation", :js => true do
  before :each do
    @user = create(:user)
    @user.skip_confirmation!
    @user.save!
    login_as(@user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  it "should create a new pin with data and images" do
    visit '/pins/new'

    find(".dz-hidden-input", visible: false)
    page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")

    attach_file("dz-file-input", Rails.root.join("spec", "fixtures", "cat.jpg"), visible: false)

    cat_img = find('#dropper img')

    expect(cat_img[:alt]).to eql("cat.jpg")
  end
end
