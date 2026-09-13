require 'rails_helper'

describe ProceduresController, :type => :controller do
  describe "#index" do
    it 'gives a list of procedures and their average sensation and satisfaction' do
      procedures = create_list(:procedure, 2)
      get :index
      expect(assigns(:procedures)).to match_array(procedures)
      expect(response).to render_template(:index)
    end
    xit 'links procedures to queries for all pins of that procedure' do
    end
  end
  describe "#show" do
    it 'prepares rating distributions only for authenticated users' do
      procedure = create(:procedure)
      user = create(:user)
      create(:pin, procedure: procedure, sensation: 5, satisfaction: 4)
      create(:pin, procedure: procedure, sensation: 5, satisfaction: 4)
      create(:pin, procedure: procedure, sensation: 2, satisfaction: 1)

      sign_in user
      get :show, id: procedure.id

      expect(assigns(:rating_distributions)).to eq(
        sensation: { 2 => 1, 5 => 2 },
        satisfaction: { 1 => 1, 4 => 2 }
      )
    end

    it 'does not prepare rating distributions for anonymous users' do
      procedure = create(:procedure)

      get :show, id: procedure.id

      expect(assigns(:rating_distributions)).to be_nil
    end
  end
end
