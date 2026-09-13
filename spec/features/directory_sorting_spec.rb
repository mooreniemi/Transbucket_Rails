require 'rails_helper'

RSpec.describe 'directory table sorting', js: true do
  after do
    Warden.test_reset!
  end

  def row_names(selector)
    all(selector).map { |row| row.find('td:first-child').text.strip }
  end

  it 'sorts procedure rows by submission count in either direction' do
    lower = create(:procedure, name: 'alpha procedure')
    higher = create(:procedure, name: 'zeta procedure')
    create_list(:pin, 2, procedure: higher)
    create(:pin, procedure: lower)

    visit '/procedures'
    expect(page).to have_selector('#procedures th button[data-sort-key="submissions"]')

    submissions_button = find('button[data-sort-key="submissions"]')
    submissions_button.click
    expect(submissions_button[:'aria-sort']).to eq('ascending')
    expect(row_names('#procedures tbody tr').first).to eq('Alpha Procedure')

    find('button[data-sort-key="submissions"]').click
    expect(row_names('#procedures tbody tr').first).to eq('Zeta Procedure')
  end

  it 'shows and sorts surgeon rating columns for signed-in users' do
    user = create(:user, :with_confirmation)
    lower = create(:surgeon, first_name: 'Alpha', last_name: 'Surgeon')
    higher = create(:surgeon, first_name: 'Zeta', last_name: 'Surgeon')
    procedure = create(:procedure)
    create(:pin, surgeon: lower, procedure: procedure, satisfaction: 1, sensation: 2)
    create(:pin, surgeon: higher, procedure: procedure, satisfaction: 5, sensation: 4)

    login_as(user, scope: :user)
    visit '/surgeons'
    expect(page).to have_selector('th button[data-sort-key="satisfaction"]')
    expect(page).to have_selector('th button[data-sort-key="sensation"]')

    satisfaction_button = find('button[data-sort-key="satisfaction"]')
    satisfaction_button.click
    expect(satisfaction_button[:'aria-sort']).to eq('ascending')
    expect(row_names('#surgeons tbody tr').first).to eq('Surgeon, Alpha')

    find('button[data-sort-key="satisfaction"]').click
    expect(row_names('#surgeons tbody tr').first).to eq('Surgeon, Zeta')
  end
end
