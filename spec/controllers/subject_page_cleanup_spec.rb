require 'rails_helper'

# Procedure and surgeon pages built from the same pieces: one header card with
# the same actions, stats in cards, the reference guide in tap-to-open
# sections, and a clear way to start a discussion.
module SubjectPageCleanup
  def doc
    @docs ||= {}
    @docs[response.body] ||= Nokogiri::HTML(response.body)
  end

  def expect_shared_header(title:, see_all:, compare:)
    header = doc.at_css('.subject-header')
    expect(header).to be_present
    expect(header.at_css('h1').text).to include(title)
    actions = header.css('.subject-actions a')
    expect(actions.map { |a| a.text.squish }).to eq(['See all submissions', 'Compare', 'Discussion'])
    expect(actions.map { |a| a['href'] }).to eq([see_all, compare, '#discussion'])
  end

  def expect_stats_cards
    expect(doc.css('.subject-stats .subject-stats-card .rating-distribution')).not_to be_empty
  end

  def expect_start_discussion(subject)
    link = doc.at_css('section#discussion a.start-discussion')
    expect(link.text.squish).to eq('Start a discussion')
    expect(link['data-remote']).to eq('true')
    expect(link['href']).to include("commentable_type=#{subject.class.name}")
  end
end

describe ProceduresController, type: :controller do
  include SubjectPageCleanup
  render_views

  let(:user) { create(:user) }
  let(:procedure) { create(:procedure, name: 'double incision') }

  before do
    sign_in(user)
    create_list(:pin, 2, procedure: procedure, sensation: 4, satisfaction: 3)
  end

  it 'uses the shared header with the same three actions' do
    get :show, params: { id: procedure.id, locale: 'en' }

    expect_shared_header(title: 'double incision',
                         see_all: pins_path(procedure: procedure.id, locale: 'en'),
                         compare: compare_path(type: 'procedures', first_id: procedure.to_param, locale: 'en'))
  end

  it 'puts the reference guide in tap-to-open sections' do
    related = create(:procedure, name: 'peri')
    allow_any_instance_of(Procedure).to receive(:editorial_guide).and_return(
      'summary' => 'A summary.',
      'sources' => [{ 'name' => 'Source', 'url' => 'https://example.org' }],
      'community_links' => [{ 'name' => 'Forum', 'url' => 'https://example.com' }]
    )
    allow_any_instance_of(Procedure).to receive(:related_procedures).and_return([related])

    get :show, params: { id: procedure.id, locale: 'en' }

    sections = doc.css('details.subject-reference')
    expect(sections.map { |d| d.at_css('summary').text.squish }).to eq(['Medical guidance and references', 'Community discussions', 'Related procedures'])
    expect(sections.map { |d| d['data-open-on-desktop'] }).to all(eq('true'))
  end

  it 'shows stats in cards and a Start a discussion button' do
    get :show, params: { id: procedure.id, locale: 'en' }

    expect_stats_cards
    expect_start_discussion(procedure)
  end
end

describe SurgeonsController, type: :controller do
  include SubjectPageCleanup
  render_views

  let(:user) { create(:user) }
  let(:surgeon) { create(:surgeon, url: 'example-clinic.org') }
  let(:procedure) { create(:procedure, name: 'double incision') }

  before do
    sign_in(user)
    create_list(:pin, 2, surgeon: surgeon, procedure: procedure, sensation: 4, satisfaction: 3)
  end

  it 'uses the shared header with the same three actions and a plain Website link' do
    get :show, params: { id: surgeon.id, locale: 'en' }

    expect_shared_header(title: surgeon.to_s,
                         see_all: pins_path(surgeon: surgeon.id, locale: 'en'),
                         compare: compare_path(type: 'surgeons', first_id: surgeon.to_param, locale: 'en'))
    website = doc.at_css('.subject-header a.subject-website')
    expect(website.text.squish).to eq('Website ↗')
    expect(website['href']).to eq('https://example-clinic.org')
    expect(response.body).not_to include("Surgeon's URL")
  end

  it 'lists each procedure as a card in the stats, with a tappable count and nothing hover-only' do
    get :show, params: { id: surgeon.id, locale: 'en' }

    expect_stats_cards
    card = doc.at_css('.subject-stats .subject-procedure-card')
    expect(card.at_css('h3').text).to include('double incision')
    badge = card.at_css('a.subject-count-badge')
    expect(badge.text.squish).to eq('2')
    expect(badge['href']).to eq(pins_path(procedure: procedure.id, surgeon: surgeon.id, locale: 'en'))
    expect(badge['style']).to be_nil
    expect(doc.at_css('.label-with-popover')).to be_nil
    expect(response.body).not_to include(I18n.t('directory.procedures_intro'))
  end

  it 'has a Start a discussion button' do
    get :show, params: { id: surgeon.id, locale: 'en' }

    expect_start_discussion(surgeon)
  end
end
