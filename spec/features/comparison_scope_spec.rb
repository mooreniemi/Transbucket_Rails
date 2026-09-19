require 'rails_helper'

RSpec.describe 'comparison scope selectors', js: true, fake_images: true do
  after { Warden.test_reset! }

  it 'filters shared surgeons immediately as procedures change' do
    user = create(:user, :with_confirmation)
    first = create(:procedure, name: 'First procedure')
    second = create(:procedure, name: 'Second procedure')
    shared = create(:surgeon, first_name: 'Shared', last_name: 'Surgeon')
    first_only = create(:surgeon, first_name: 'First', last_name: 'Only')
    create(:pin, procedure: first, surgeon: shared)
    create(:pin, procedure: second, surgeon: shared)
    create(:pin, procedure: first, surgeon: first_only)

    login_as(user, scope: :user)
    visit '/procedures/compare'
    expect(page).to have_checked_field('deduplicate_comparison')
    find("#first_id option[value='#{first.to_param}']").select_option
    expect(page).to have_css("#surgeon_id option[value='#{shared.to_param}']:not([disabled])")
    expect(page).to have_css("#surgeon_id option[value='#{first_only.to_param}']:not([disabled])")

    find("#second_id option[value='#{second.to_param}']").select_option
    expect(page).to have_css("#surgeon_id option[value='#{shared.to_param}']:not([disabled])")
    expect(page).to have_no_css("#surgeon_id option[value='#{first_only.to_param}']:not([disabled])")
  end

  it 'filters shared procedures immediately as surgeons change' do
    user = create(:user, :with_confirmation)
    first = create(:surgeon, first_name: 'First', last_name: 'Surgeon')
    second = create(:surgeon, first_name: 'Second', last_name: 'Surgeon')
    shared = create(:procedure, name: 'Shared procedure')
    first_only = create(:procedure, name: 'First only procedure')
    create(:pin, surgeon: first, procedure: shared)
    create(:pin, surgeon: second, procedure: shared)
    create(:pin, surgeon: first, procedure: first_only)

    login_as(user, scope: :user)
    visit '/surgeons/compare'
    expect(page).to have_checked_field('deduplicate_comparison')
    find("#first_id option[value='#{first.to_param}']").select_option
    expect(page).to have_css("#procedure_id option[value='#{shared.to_param}']:not([disabled])")
    expect(page).to have_css("#procedure_id option[value='#{first_only.to_param}']:not([disabled])")

    find("#second_id option[value='#{second.to_param}']").select_option
    expect(page).to have_css("#procedure_id option[value='#{shared.to_param}']:not([disabled])")
    expect(page).to have_no_css("#procedure_id option[value='#{first_only.to_param}']:not([disabled])")
  end

  it 'compares shared and distinct complication rates' do
    user = create(:user, :with_confirmation)
    first = create(:procedure, name: 'First procedure')
    second = create(:procedure, name: 'Second procedure')

    [
      [first, 'hematoma, fistula'],
      [first, 'hematoma'],
      [first, ''],
      [second, 'hematoma, infection'],
      [second, '']
    ].each do |procedure, complications|
      pin = create(:pin, procedure: procedure)
      pin.complication_list = complications
      pin.save!
    end

    login_as(user, scope: :user)
    visit "/procedures/compare?first_id=#{first.to_param}&second_id=#{second.to_param}"

    within('.comparison-complications') do
      expect(page).to have_content('hematoma')
      expect(page).to have_content('67% of submissions')
      expect(page).to have_content('50% of submissions')
      expect(page).to have_content('Both (First +17 points)')
      expect(page).to have_content('fistula')
      expect(page).to have_content('First only')
      expect(page).to have_content('infection')
      expect(page).to have_content('Second only')
    end
  end
end
