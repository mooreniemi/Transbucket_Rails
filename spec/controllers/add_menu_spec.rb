require 'rails_helper'

# Creating from the menu, on every page: on phones two rows in the menu
# (Add submission, Start a discussion); on desktop one "Add" dropdown with
# both, so the navbar doesn't wrap. Start a discussion goes to the feed with
# the discussion form already open.
describe ProceduresController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in(user) }

  def doc
    Nokogiri::HTML(response.body)
  end

  def tracked_id(link)
    link['data-content-id'].to_i
  end

  it 'offers both as rows in the phone menu, tracked separately' do
    get :index, params: { locale: 'en' }

    rows = doc.css('.navbar-collapse li.visible-xs a')
    submission = rows.find { |a| a.text.squish == 'Add submission' }
    discussion = rows.find { |a| a.text.squish == 'Start a discussion' }
    expect(submission['href']).to eq(new_pin_path(locale: 'en'))
    expect(tracked_id(submission)).to eq(TrackedTarget.id_for(:add))
    expect(discussion['href']).to eq(pins_path(locale: 'en', compose: 1))
    expect(tracked_id(discussion)).to eq(TrackedTarget.id_for(:add_discussion))
  end

  it 'offers both under one Add dropdown on desktop' do
    get :index, params: { locale: 'en' }

    menu = doc.at_css('.navbar-collapse li.add-menu.hidden-xs')
    expect(menu.at_css('a.dropdown-toggle').text.squish).to eq('Add')
    items = menu.css('.dropdown-menu a')
    expect(items.map { |a| a.text.squish }).to eq(%w[Submission Discussion])
    expect(items.map { |a| a['href'] }).to eq([new_pin_path(locale: 'en'), pins_path(locale: 'en', compose: 1)])
    expect(items.map { |a| tracked_id(a) }).to eq([TrackedTarget.id_for(:add), TrackedTarget.id_for(:add_discussion)])
  end

  it "keeps Start a discussion for accounts that can't add a submission" do
    user.update!(gender: create(:gender, name: 'Cisgender'))

    get :index, params: { locale: 'en' }

    texts = doc.css('.navbar-collapse a').map { |a| a.text.squish }
    expect(texts).to include('Start a discussion', 'Discussion')
    expect(texts).not_to include('Add submission', 'Submission')
  end
end

describe PinsController, type: :controller do
  render_views

  before { sign_in(create(:user)) }

  it 'opens the discussion form when asked to, instead of the filter' do
    get :index, params: { locale: 'en', compose: '1', procedure: [create(:procedure).id.to_s] }

    doc = Nokogiri::HTML(response.body)
    expect(doc.at_css('#feed-compose-panel')['class'].split).to include('in')
    expect(doc.at_css('#feed-filter-panel')['class'].split).not_to include('in')
    expect(doc.at_css('.feed-toolbar .feed-compose-toggle')['aria-expanded']).to eq('true')
  end
end

describe TrackedTarget do
  it 'adds Start a discussion from the menu at the end' do
    expect(TrackedTarget.id_for(:add_discussion)).to eq(27)
  end
end

describe ProceduresController, type: :controller do
  render_views

  it 'gives Compare a little flair: yellow scales, like the yellow plus on Add' do
    sign_in(create(:user))

    get :index, params: { locale: 'en' }

    compare = Nokogiri::HTML(response.body).css('.navbar-collapse a').find { |a| a.text.squish == 'Compare' }
    expect(compare.at_css('.fa-balance-scale.yellow')).to be_present
    expect(compare['data-content-id'].to_i).to eq(TrackedTarget.id_for(:compare))
  end
end
