require 'rails_helper'

RSpec.describe 'pin detail typography', js: true, fake_images: true do
  it 'keeps detail paragraphs readable on a phone-sized screen' do
    user = create(:user, :with_confirmation)
    pin = create(:pin, :with_surgeon_and_procedure, user: user)
    pin.update_attributes!(details: "First paragraph of an experience.\n\nSecond paragraph with a separate thought.")
    page.current_window.resize_to(375, 800)
    Rails.cache.clear
    login_as(user, scope: :user)

    visit "/pins/#{pin.id}"
    expect(pin.reload.details).to include('First paragraph')
    expect(page).to have_css('#details')

    typography = page.evaluate_script(<<-JAVASCRIPT)
      (function() {
        var paragraph = document.querySelector('#details p');
        var styles = window.getComputedStyle(paragraph);
        return {
          display: styles.display,
          fontSize: parseFloat(styles.fontSize),
          lineHeight: parseFloat(styles.lineHeight),
          paragraphCount: document.querySelectorAll('#details p').length
        };
      }())
    JAVASCRIPT

    expect(typography['display']).to eq('block')
    expect(typography['fontSize']).to be >= 17
    expect(typography['lineHeight']).to be >= 27
    expect(typography['paragraphCount']).to eq(2)
  end
end
