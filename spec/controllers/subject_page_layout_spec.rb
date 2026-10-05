require 'rails_helper'

# Procedure and surgeon pages share one order: info, recent submissions, stats,
# then the discussion at the bottom, with a jump link to it near the top
# (these pages get long on a phone).
module SubjectPageLayout
  # One parse per response, so nodes compare by identity across the helpers.
  def doc
    @docs ||= {}
    @docs[response.body] ||= Nokogiri::HTML(response.body)
  end

  # Document order of the given selectors (first match each).
  def positions(*selectors)
    nodes = doc.css('*').to_a
    selectors.map do |selector|
      node = doc.at_css(selector)
      raise "missing #{selector}" unless node
      nodes.index(node)
    end
  end

  def expect_discussion_last(*earlier)
    order = positions(*earlier, 'section#discussion')
    expect(order).to eq(order.sort)
    discussion = doc.at_css('section#discussion')
    expect(discussion.at_css('h2').text).to include('Discussion')
    # Nothing but the page footer after it: no other content section follows.
    all = doc.css('*').to_a
    inside = discussion.css('*').to_a
    later = doc.css('section, .panel').select { |node| all.index(node) > all.index(discussion) && !inside.include?(node) }
    expect(later).to be_empty
  end

  def expect_jump_link(count_text)
    jump = doc.at_css('a.discussion-jump')
    expect(jump['href']).to eq('#discussion')
    expect(jump.text.squish).to eq(count_text)
    expect(positions('a.discussion-jump', 'section#discussion').first).to be < positions('section#discussion').first
  end
end

describe ProceduresController, type: :controller do
  include SubjectPageLayout
  render_views

  let(:user) { create(:user) }
  let(:procedure) { create(:procedure) }

  before do
    sign_in(user)
    create_list(:pin, 2, procedure: procedure, sensation: 4, satisfaction: 3)
  end

  it 'puts info, recent submissions, stats, then the discussion at the bottom' do
    get :show, params: { id: procedure.id, locale: 'en' }

    expect_discussion_last('h1', '.procedure-recent-submissions', '.procedure-stats')
  end

  it 'links to the discussion from the top, with how many comments there are' do
    root = Comment.create!(commentable: procedure, user: user, body: 'First')
    Comment.create!(commentable: procedure, user: user, body: 'Reply').move_to_child_of(root)
    Comment.create!(commentable: procedure, user: user, body: 'Hidden', state: 'pending')

    get :show, params: { id: procedure.id, locale: 'en' }

    expect_jump_link('Discussion (2)')
  end

  it 'puts the jump link in the page header, above the guide, so it is on the first screen of a phone' do
    allow_any_instance_of(Procedure).to receive(:editorial_guide).and_return(
      'summary' => 'A summary.', 'sources' => [{ 'name' => 'Source', 'url' => 'https://example.org' }]
    )

    get :show, params: { id: procedure.id, locale: 'en' }

    expect(doc.at_css('.subject-header a.discussion-jump')).to be_present
    expect(positions('a.discussion-jump', '.procedure-guide')).to eq(positions('a.discussion-jump', '.procedure-guide').sort)
  end

  it 'still links to an empty discussion, without a count' do
    get :show, params: { id: procedure.id, locale: 'en' }

    expect_jump_link('Discussion')
  end
end

describe SurgeonsController, type: :controller do
  include SubjectPageLayout
  render_views

  let(:user) { create(:user) }
  let(:surgeon) { create(:surgeon) }

  before do
    sign_in(user)
    create_list(:pin, 2, surgeon: surgeon, sensation: 4, satisfaction: 3)
  end

  it 'puts info, recent submissions, stats (overall and per procedure), then the discussion at the bottom' do
    get :show, params: { id: surgeon.id, locale: 'en' }

    expect_discussion_last('h1', '.procedure-recent-submissions', '.surgeon-stats', '.surgeon-procedure-breakdown')
  end

  it 'links to the discussion from the top, with how many comments there are' do
    Comment.create!(commentable: surgeon, user: user, body: 'One')

    get :show, params: { id: surgeon.id, locale: 'en' }

    expect_jump_link('Discussion (1)')
  end

  context 'with fragment caching on, as on staging and production' do
    around do |example|
      caching, store = ActionController::Base.perform_caching, ActionController::Base.cache_store
      ActionController::Base.perform_caching = true
      ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
      begin
        example.run
      ensure
        ActionController::Base.perform_caching = caching
        ActionController::Base.cache_store = store
      end
    end

    it 'shows a new comment on the next visit (the discussion is not cached with the page)' do
      get :show, params: { id: surgeon.id, locale: 'en' }
      Comment.create!(commentable: surgeon, user: user, body: 'Posted after the page was cached')

      get :show, params: { id: surgeon.id, locale: 'en' }

      expect(doc.at_css('section#discussion').text).to include('Posted after the page was cached')
      expect_jump_link('Discussion (1)')
    end
  end
end
