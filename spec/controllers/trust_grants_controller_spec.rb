require 'rails_helper'

describe TrustGrantsController, type: :controller do
  render_views

  let(:admin) { create(:user, admin: true) }

  describe 'GET #index' do
    it 'allows admins to see the trust console' do
      sign_in(admin)

      get :index

      expect(response).to be_success
      expect(response.body).to include('Community trust')
      expect(response.body).to include('Enter at least 3 characters to search for a member and manage their roles.')
    end

    it 'forbids non-admin users' do
      sign_in(create(:user))

      get :index

      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids a Moderator from managing roles' do
      moderator = create(:user)
      moderator.grant_trust!('moderator', granted_by: admin)
      sign_in(moderator)

      get :index

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET #index with a search' do
    it 'does not query the member directory for fewer than three characters' do
      sign_in(admin)

      get :index, query: 'zo'

      expect(response.body).to include('Enter at least 3 characters to search.')
    end

    it 'returns at most matching members rather than rendering the member directory' do
      matching_user = create(:user, username: 'helpful_contributor', name: 'Helpful Member')
      create(:user, username: 'unrelated_member', name: 'Someone Else')
      sign_in(admin)

      get :index, query: 'helpful'

      expect(response.body).to include(matching_user.username)
      expect(response.body).not_to include('unrelated_member')
    end
  end

  describe 'POST #create' do
    it 'records a moderator-granted moderator role with an internal note' do
      member = create(:user)
      sign_in(admin)

      post :create, user_id: member.id, user_trust_grant: { kind: 'moderator', internal_note: 'Prototype grant' }

      grant = member.trust_grants.find_by(kind: 'moderator')
      expect(grant).to be_present
      expect(grant.granted_by).to eq(admin)
      expect(grant.source).to eq('moderator')
      expect(grant.internal_note).to eq('Prototype grant')
    end
  end

  describe 'DELETE #destroy' do
    it 'does not allow automatic Contributor grants to be revoked manually' do
      member = create(:user)
      grant = member.grant_trust!('contributor')
      sign_in(admin)

      delete :destroy, id: grant.id

      expect(response).to have_http_status(:forbidden)
      expect(grant.reload).to be_active
    end
  end
end
