require 'rails_helper'

describe ProceduresController, :type => :controller do
  describe "#index" do
    it 'gives a list of procedures and their average sensation and satisfaction' do
      procedures = create_list(:procedure, 2)
      get :index
      expect(assigns(:procedures)).to match_array(procedures)
      expect(response).to render_template(:index)
    end

    it 'loads rating averages in grouped queries for the directory rows' do
      user = create(:user)
      procedure = create(:procedure)
      create(:pin, procedure: procedure, sensation: 3, satisfaction: 4)
      create(:pin, procedure: procedure, sensation: 5, satisfaction: 2)

      sign_in user
      get :index

      expect(assigns(:avg_sensation_by_procedure)[procedure.id]).to eq(4.0)
      expect(assigns(:avg_satisfaction_by_procedure)[procedure.id]).to eq(3.0)
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

    it 'loads the latest published submissions for authenticated users' do
      procedure = create(:procedure)
      user = create(:user)
      latest = create(:pin, procedure: procedure, updated_at: 1.day.ago)
      create(:pin, procedure: procedure, updated_at: 2.days.ago)
      create(:pin, procedure: procedure, updated_at: 3.days.ago)
      create(:pin, procedure: procedure, updated_at: 4.days.ago)

      sign_in user
      get :show, id: procedure.id

      expect(assigns(:latest_pins).length).to eq(3)
      expect(assigns(:latest_pins)).to include(latest)
    end

    it 'does not prepare rating distributions for anonymous users' do
      procedure = create(:procedure)

      get :show, id: procedure.id

      expect(assigns(:rating_distributions)).to be_nil
    end

    it 'preloads configured related procedures without requiring every reference to exist' do
      procedure = create(:procedure, name: 'phalloplasty')
      related = create(:procedure, name: 'rff phalloplasty')

      get :show, id: procedure.id

      expect(assigns(:related_procedures)).to include(related)
      expect(response).to be_success
    end

    it 'finds related procedures that share a meaningful procedure term' do
      procedure = create(:procedure, name: 'phalloplasty')
      related = create(:procedure, name: 'groin flap phalloplasty')
      unrelated = create(:procedure, name: 'hysterectomy')

      get :show, id: procedure.id

      expect(assigns(:related_procedures)).to include(related)
      expect(assigns(:related_procedures)).not_to include(unrelated)
    end

    it 'builds grouped rating data for two compared procedures' do
      user = create(:user)
      first = create(:procedure)
      second = create(:procedure)
      create(:pin, procedure: first, sensation: 5, satisfaction: 4)
      create(:pin, procedure: second, sensation: 2, satisfaction: 1)

      sign_in user
      get :compare, first_id: first.to_param, second_id: second.to_param

      expect(response).to be_success
      expect(assigns(:comparison_data)[first][:distributions][:sensation]).to eq(5 => 1)
      expect(assigns(:comparison_data)[second][:distributions][:satisfaction]).to eq(1 => 1)
    end
  end
end
