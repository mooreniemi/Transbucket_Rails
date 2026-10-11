require 'rails_helper'

describe CommentsController, :type => :controller do
  render_views

  let(:user) { create(:user) }
  let(:pin) { create(:pin, :with_surgeon_and_procedure) }
  let(:surgeon) { create(:surgeon) }

  before(:each) do
    sign_in(user)
  end

  describe 'GET #new' do
    it "builds a comment for an allowed commentable_type" do
      get :new, params: { commentable_type: "Pin", commentable_id: pin.id, locale: 'en' }, xhr: true

      expect(response).to have_http_status(:success)
    end

    it "renders the comment form in the selected locale" do
      get :new, params: { commentable_type: "Pin", commentable_id: pin.id, locale: 'es' }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Añade un comentario')
      expect(response.body).to include('Publicar')
    end

    it "rejects a commentable_type outside the allowed list" do
      get :new, params: { commentable_type: "User", commentable_id: user.id, locale: 'en' }, xhr: true

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST #create' do
    it "creates a comment for an allowed commentable_type" do
      post :create, params: { comment: { commentable_type: "Pin", commentable_id: pin.id, body: "nice pin" } }, xhr: true

      expect(response).to have_http_status(:success)
      expect(Comment.count).to eq(1)
    end

    it "creates a comment on a surgeon" do
      post :create, params: { comment: { commentable_type: "Surgeon", commentable_id: surgeon.id, body: "great surgeon" } }, xhr: true

      expect(response).to have_http_status(:success)
      expect(Comment.last.commentable).to eq(surgeon)
    end

    it 'stores a selected visibility for a contextual discussion' do
      procedure = create(:procedure)

      post :create, params: { comment: { commentable_type: 'Procedure', commentable_id: procedure.id, body: 'contributors only', visibility: 'contributors' } }, xhr: true

      expect(response).to have_http_status(:created)
      expect(Comment.last.visibility).to eq('contributors')
    end

    it 'inherits the root visibility for replies' do
      procedure = create(:procedure)
      root = create(:comment, commentable: procedure, visibility: 'subject_contributors')
      create(:pin, user: user, procedure: procedure) # so they can read the thread

      post :create, params: { comment: { commentable_type: 'Procedure', commentable_id: procedure.id, parent_id: root.id, body: 'reply', visibility: 'everyone' } }, xhr: true

      expect(response).to have_http_status(:created)
      expect(Comment.last.visibility).to eq('subject_contributors')
    end

    it 'keeps submission comments public even if a forged visibility is submitted' do
      post :create, params: { comment: { commentable_type: 'Pin', commentable_id: pin.id, body: 'public pin comment', visibility: 'contributors' } }, xhr: true

      expect(response).to have_http_status(:created)
      expect(Comment.last.visibility).to eq('everyone')
    end

    it "rejects a commentable_type outside the allowed list without touching the database" do
      post :create, params: { comment: { commentable_type: "User", commentable_id: user.id, body: "gotcha" } }, xhr: true

      expect(response).to have_http_status(:bad_request)
      expect(Comment.count).to eq(0)
    end
  end
end
