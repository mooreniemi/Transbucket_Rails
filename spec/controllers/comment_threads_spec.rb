require 'rails_helper'

# One discussion on its own page (/comments/:id): the post, its replies and a
# way to reply. The phone feed opens it over the feed (pin_viewer.js) with
# ?viewer=1, which leaves the layout out, as pin pages do.
describe CommentsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:procedure) { create(:procedure, name: 'double incision') }
  let(:body) { (1..80).map { |i| "word#{i}" }.join(' ') }
  let!(:root) { Comment.create!(commentable: procedure, user: author, body: body) }

  def doc
    Nokogiri::HTML(response.body)
  end

  context 'when signed in' do
    before { sign_in(user) }

    it 'shows the whole post with its replies and where it was posted' do
      reply = Comment.create!(commentable: procedure, user: user, body: 'A reply')
      reply.move_to_child_of(root)

      get :show, params: { id: root.id, locale: 'en' }

      expect(response).to have_http_status(:ok)
      expect(doc.at_css("#comment-#{root.id} > .comment-body").text).to include('word80')
      expect(doc.at_css("#comment-#{root.id} .comment-replies #comment-#{reply.id}")).to be_present
      expect(doc.at_css("#comment-#{root.id} .comment-reply")).to be_present
      context_link = doc.at_css('.comment-thread-context a')
      expect(context_link.text.strip).to eq('double incision')
      expect(context_link['href']).to eq(procedure_path(procedure, locale: 'en', anchor: 'comments-container'))
      expect(doc.at_css('.pin-page-title').text).to include('double incision')
    end

    it 'leaves the layout out for the phone viewer' do
      get :show, params: { id: root.id, locale: 'en', viewer: '1' }

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('<html')
      expect(doc.at_css("#comment-#{root.id}")).to be_present
    end

    it 'sends a reply to its discussion, at that reply, keeping viewer and reply_to' do
      reply = Comment.create!(commentable: procedure, user: user, body: 'A reply')
      reply.move_to_child_of(root)

      get :show, params: { id: reply.id, locale: 'en', viewer: '1', reply_to: reply.id }

      expect(response).to redirect_to(comment_path(root, locale: 'en', viewer: '1', reply_to: reply.id, anchor: "comment-#{reply.id}"))
    end

    it 'sends a comment on a submission to the submission page' do
      pin = create(:pin)
      on_pin = Comment.create!(commentable: pin, user: author, body: 'On a pin')

      get :show, params: { id: on_pin.id, locale: 'en' }

      expect(response).to redirect_to(pin_path(pin, locale: 'en', anchor: "comment-#{on_pin.id}"))
    end

    it 'does not show a discussion that is waiting for review' do
      root.update_columns(state: 'pending')

      expect { get :show, params: { id: root.id, locale: 'en' } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it 'asks you to sign in first' do
    get :show, params: { id: root.id, locale: 'en' }

    expect(response).to redirect_to(new_user_session_path(locale: 'en'))
  end
end
