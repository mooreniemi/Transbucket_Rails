require 'rails_helper'

RSpec.describe SurgeonsController, :type => :controller do
  describe "#index" do
    it 'gives a list of surgeons' do
      surgeons = create_list(:surgeon, 2)
      get :index
      expect(assigns(:surgeons)).to match_array(surgeons)
      expect(response).to render_template(:index)
    end

    it 'loads rating averages for signed-in users' do
      user = create(:user)
      low = create(:surgeon, first_name: 'Low', last_name: 'Rating')
      high = create(:surgeon, first_name: 'High', last_name: 'Rating')
      procedure = create(:procedure)
      create(:pin, surgeon: low, procedure: procedure, sensation: 1, satisfaction: 2)
      create(:pin, surgeon: high, procedure: procedure, sensation: 5, satisfaction: 4)

      sign_in user
      get :index

      expect(assigns(:avg_sensation_by_surgeon)[high.id]).to eq(5.0)
      expect(assigns(:avg_satisfaction_by_surgeon)[low.id]).to eq(2.0)
    end

    it 'does not expose rating aggregates to anonymous users' do
      low = create(:surgeon, first_name: 'Low', last_name: 'Rating')
      high = create(:surgeon, first_name: 'High', last_name: 'Rating')
      procedure = create(:procedure)
      create(:pin, surgeon: low, procedure: procedure, sensation: 1)
      create(:pin, surgeon: high, procedure: procedure, sensation: 5)

      get :index

      expect(assigns(:avg_sensation_by_surgeon)).to eq({})
    end
    xit 'links surgeons to queries for all pins of that surgeon' do
    end
  end
  describe "#show" do
    it 'scopes per-procedure pin counts to the surgeon being viewed' do
      surgeon = create(:surgeon)
      other_surgeon = create(:surgeon)
      procedure_a = create(:procedure)
      procedure_b = create(:procedure)

      create_list(:pin, 2, surgeon: surgeon, procedure: procedure_a)
      create(:pin, surgeon: surgeon, procedure: procedure_b)
      # pins belonging to a different surgeon must not affect this surgeon's counts
      create_list(:pin, 5, surgeon: other_surgeon, procedure: procedure_a)

      get :show, id: surgeon.id

      counts = assigns(:pins_by_surgeon_procedure)
      expect(counts[procedure_a.id]).to eq(2)
      expect(counts[procedure_b.id]).to eq(1)
      expect(counts.values.sum).to eq(3)
      expect(assigns(:procedure_count)).to eq(2)
      expect(assigns(:submission_count)).to eq(3)
      expect(assigns(:procedures_by_id)).to include(procedure_a.id => procedure_a, procedure_b.id => procedure_b)
    end
  end
end
