require 'rails_helper'

# The feed toolbar: Filter, + Discussion and + Submission. Filter and
# + Discussion each open a form above the feed; + Submission goes to the
# submission form. Recent / For You is a choice inside Filter (for people who
# get a For You feed), and it works together with the other filters.
describe PinsController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in(user) }

  def doc
    Nokogiri::HTML(response.body)
  end

  def toolbar
    doc.at_css('.feed-toolbar')
  end

  it 'offers Filter, + Discussion and + Submission, in that order' do
    get :index, params: { locale: 'en' }

    labels = toolbar.css('.feed-toolbar-action').map { |action| action.text.squish }
    expect(labels).to eq(['Filter', 'Discussion', 'Submission'])
    expect(toolbar.at_css('.feed-filter-toggle')['data-target']).to eq('#feed-filter-panel')
    expect(toolbar.at_css('.feed-compose-toggle')['data-target']).to eq('#feed-compose-panel')
    expect(toolbar.at_css('a.feed-add-submission')['href']).to eq(new_pin_path(locale: 'en'))
  end

  it 'opens + Discussion as a form above the feed, not a separate page' do
    get :index, params: { locale: 'en' }

    form = doc.at_css('#feed-compose-panel form.discussion-form')
    expect(form['action']).to eq(discussions_path(locale: 'en'))
    expect(form.at_css('input[name="discussion[title]"]')).to be_present
    expect(form.at_css('textarea[name="discussion[body]"]')).to be_present
    expect(form.css('input[type=radio][name="discussion[category]"]').map { |r| r['value'] }).to eq(Discussion::CATEGORIES)
    expect(form.css('input[type=radio][name="discussion[visibility]"]').map { |r| r['value'] }).to eq(%w[everyone contributors])
    expect(doc.at_css('a.start-discussion-feed')).to be_nil
  end

  it "leaves out + Submission for accounts that can't add one" do
    user.update!(gender: create(:gender, name: 'Cisgender'))

    get :index, params: { locale: 'en' }

    expect(toolbar.css('.feed-toolbar-action').map { |action| action.text.squish }).to eq(['Filter', 'Discussion'])
  end

  it 'has no Recent / For You tabs or "paused" hint any more' do
    user.update!(gender: create(:gender, name: 'MTF'))

    get :index, params: { locale: 'en', procedure: [create(:procedure).id.to_s] }

    expect(doc.at_css('.submission-feed-tabs')).to be_nil
    expect(doc.at_css('.feed-tabs-paused')).to be_nil
  end

  context 'for someone who gets a For You feed' do
    before { user.update!(gender: create(:gender, name: 'MTF')) }

    def show_choices
      doc.css('#feed-filter-panel input[type=radio][name=feed]')
    end

    it 'offers Recent / For You inside Filter, Recent by default' do
      get :index, params: { locale: 'en' }

      expect(show_choices.map { |r| r['value'] }).to eq(%w[recent for_you])
      expect(show_choices.find { |r| r['checked'] }['value']).to eq('recent')
      expect(toolbar.at_css('.feed-filter-toggle').text.squish).to eq('Filter')
    end

    it 'keeps For You chosen and names it on the Filter button' do
      get :index, params: { locale: 'en', feed: 'for_you' }

      expect(show_choices.find { |r| r['checked'] }['value']).to eq('for_you')
      expect(toolbar.at_css('.feed-filter-toggle').text.squish).to eq('Filter · For You')
    end

    it 'applies For You together with other filters instead of pausing it' do
      surgeon = create(:surgeon)
      mine = create(:pin, surgeon: surgeon, procedure: create(:procedure, gender: 'MTF'))
      other = create(:pin, surgeon: surgeon, procedure: create(:procedure, gender: 'FTM'))
      create(:gender, name: 'FTM')

      get :index, params: { locale: 'en', feed: 'for_you', surgeon: [surgeon.id.to_s] }

      ids = doc.css('[data-pin-id]').map { |card| card['data-pin-id'].to_i }
      expect(ids).to include(mine.id)
      expect(ids).not_to include(other.id)
    end
  end

  it 'offers no Recent / For You choice to someone without a For You feed' do
    user.update!(gender: create(:gender, name: 'GenderQueer'))

    get :index, params: { locale: 'en' }

    expect(doc.css('input[name=feed]')).to be_empty
    expect(toolbar.at_css('.feed-filter-toggle').text.squish).to eq('Filter')
  end
end

# Posting from the feed's form: the new card comes back to go at the top of
# the feed; a mistake comes back as the form with what to fix.
describe DiscussionsController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in(user) }

  it 'answers a post from the feed with its card' do
    post :create, params: { locale: 'en', discussion: { title: 'Recovery questions', body: 'What helped?', category: 'recovery', visibility: 'everyone' } }, xhr: true

    discussion = Discussion.last
    expect(response).to have_http_status(:created)
    card = Nokogiri::HTML(response.body).at_css(".feed-discussion[data-feed-key='discussion-#{discussion.id}']")
    expect(card).to be_present
    expect(card.text).to include('Recovery questions')
  end

  it 'answers a mistake with the form and what to fix' do
    post :create, params: { locale: 'en', discussion: { title: '', body: '', category: 'question', visibility: 'everyone' } }, xhr: true

    expect(response).to have_http_status(:unprocessable_entity)
    form = Nokogiri::HTML(response.body).at_css('form.discussion-form')
    expect(form.css('.help-block, .error').text).to include("can't be blank")
    expect(form.at_css('input[type=radio][value=question]')['checked']).to be_present
  end
end
