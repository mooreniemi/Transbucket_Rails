require 'rails_helper'

RSpec.describe DiscussionsController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in(user) }

  it 'creates a text-only discussion and redirects to its thread page' do
    expect {
      post :create, params: { locale: 'en', discussion: { title: 'Recovery questions', body: 'What helped you most?', visibility: 'contributors' } }
    }.to change(Discussion, :count).by(1)

    discussion = Discussion.last
    expect(response).to redirect_to(discussion_path(discussion, locale: 'en'))
    expect(discussion.visibility).to eq('contributors')
  end

  it 'renders the post and its replies' do
    discussion = create(:discussion, user: user, title: 'General topic', body: 'Opening post')
    CommentService.new(discussion, user, 'A reply').tap(&:create)

    get :show, params: { locale: 'en', id: discussion.id }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('General topic', 'Opening post', 'A reply')
  end

  it 'does not expose a contributor-only post to an ordinary reader' do
    discussion = create(:discussion, visibility: 'contributors')

    expect { get :show, params: { locale: 'en', id: discussion.id } }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
