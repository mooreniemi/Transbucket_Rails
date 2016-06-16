require "rails_helper"

RSpec.describe "registration" do
  let!(:genders) { create_list(:gender, 5) }
  let(:user) { build(:user, gender: genders.last) }

  def fill_out_sign_up(user)
    visit '/register'

    fill_in "Your name", :with => user.name
    fill_in "Username", :with => user.username
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    fill_in "Password confirmation", :with => user.password
    select user.gender.name, :from => "user_gender_id"
  end

  def login_user(user, remember: false)
    fill_in "Username", :with => user.username
    fill_in "Password", :with => user.password
    check "user_remember_me" if remember

    click_button "Sign in"
  end

  it "creates a new user that can sign in" do
    fill_out_sign_up(user)

    clear_emails

    click_button "Submit"

    expect(page).to have_content("A message with a confirmation link")

    open_email(user.email)
    current_email.click_link 'Confirm my account'

    expect(page).to have_content("Your account was successfully confirmed")

    login_user(user, remember: true)

    expect(current_path).to eq('/pins')

    user_in_db = User.find_by!(email: user.email)

    expect(user_in_db.confirmed_at).not_to be nil
    expect(user_in_db.gender_id.to_i).to eq(user.gender.id)
  end

end
