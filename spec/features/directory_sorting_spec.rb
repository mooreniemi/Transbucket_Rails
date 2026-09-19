require 'rails_helper'

RSpec.describe 'directory table sorting', js: true, fake_images: true do
  before do
    page.current_window.resize_to(1280, 900)
  end

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

  it 'keeps directory headers sticky without trapping them in a scrolling wrapper' do
    procedure = create(:procedure)

    visit '/procedures'

    styles = page.evaluate_script(<<-JAVASCRIPT)
      (function() {
        return {
          headerPosition: window.getComputedStyle(document.querySelector('#procedures thead th')).position,
          wrapperOverflow: window.getComputedStyle(document.querySelector('#procedures')).overflow
        };
      }())
    JAVASCRIPT

    expect(styles['headerPosition']).to eq('sticky')
    expect(styles['wrapperOverflow']).to eq('visible')
    expect(first('#procedures tbody tr td')['data-label']).to eq(I18n.t('directory.name'))
  end

  it 'uses labeled rows on narrow screens' do
    create(:procedure)
    page.current_window.resize_to(375, 800)

    visit '/procedures'

    styles = page.evaluate_script(<<-JAVASCRIPT)
      (function() {
        var cell = document.querySelector('#procedures tbody tr td');
        return {
          headerPosition: window.getComputedStyle(document.querySelector('#procedures thead')).position,
          label: window.getComputedStyle(cell, ':before').content
        };
      }())
    JAVASCRIPT

    expect(styles['headerPosition']).to eq('absolute')
    expect(styles['label']).to include(I18n.t('directory.name'))
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

  it 'shows sort icons and links procedure rating buckets to filtered submissions' do
    user = create(:user, :with_confirmation)
    procedure = create(:procedure)
    create(:pin, procedure: procedure, satisfaction: 5, sensation: 2)
    create(:pin, procedure: procedure, satisfaction: 3, sensation: 2)

    login_as(user, scope: :user)
    visit '/procedures'

    expect(page).to have_selector('.directory-sort-button .fa-sort', count: 5)
    visit "/procedures/#{procedure.to_param}"
    expect(page).to have_selector('h4', text: I18n.t('public.rating.satisfaction.distribution'))
    expect(page).to have_link('1', href: /satisfaction=5/)
  end

  it 'shows overall and per-procedure rating buckets on surgeon pages' do
    user = create(:user, :with_confirmation)
    surgeon = create(:surgeon)
    procedure = create(:procedure)
    create(:pin, surgeon: surgeon, procedure: procedure, satisfaction: 5, sensation: 4)

    login_as(user, scope: :user)
    visit "/surgeons/#{surgeon.to_param}"

    expect(page).to have_selector('.surgeon-rating-distributions')
    expect(page).to have_selector('.surgeon-procedure-rating-distributions')
    expect(page).to have_selector("a.rating-distribution-count-link[href*='surgeon=#{surgeon.id}'][href*='satisfaction=5']", text: '1')
  end
end
