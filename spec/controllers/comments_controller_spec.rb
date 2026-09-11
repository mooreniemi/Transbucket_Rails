require 'rails_helper'

describe CommentsController, :type => :controller do
  render_views

  let(:user) { create(:user) }
  let(:pin) { create(:pin, :with_surgeon_and_procedure) }

  before(:each) do
    sign_in(user)
  end

  describe 'GET #new' do
    it "builds a comment for an allowed commentable_type" do
      xhr :get, :new, commentable_type: "Pin", commentable_id: pin.id

      expect(response).to be_success
    end

    it "renders the comment form in the selected locale" do
      xhr :get, :new, commentable_type: "Pin", commentable_id: pin.id, locale: 'es'

      expect(response).to be_success
      expect(response.body).to include('Los comentarios que infrinjan')
    end

    it "rejects a commentable_type outside the allowed list" do
      xhr :get, :new, commentable_type: "User", commentable_id: user.id

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST #create' do
    it "creates a comment for an allowed commentable_type" do
      xhr :post, :create, comment: { commentable_type: "Pin", commentable_id: pin.id, body: "nice pin" }

      expect(response).to be_success
      expect(Comment.count).to eq(1)
    end

    it "rejects a commentable_type outside the allowed list without touching the database" do
      xhr :post, :create, comment: { commentable_type: "User", commentable_id: user.id, body: "gotcha" }

      expect(response).to have_http_status(:bad_request)
      expect(Comment.count).to eq(0)
    end
  end
end
