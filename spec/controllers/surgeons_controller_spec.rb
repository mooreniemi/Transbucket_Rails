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
    it 'loads overall rating averages for signed-in users' do
      user = create(:user)
      surgeon = create(:surgeon)
      procedure = create(:procedure)
      create(:pin, surgeon: surgeon, procedure: procedure, sensation: 3, satisfaction: 5)
      create(:pin, surgeon: surgeon, procedure: procedure, sensation: 5, satisfaction: 1)

      sign_in user
      get :show, id: surgeon.id

      expect(assigns(:overall_satisfaction)).to eq(3.0)
      expect(assigns(:overall_sensation)).to eq(4.0)
    end

    it 'loads overall and per-procedure rating distributions for signed-in users' do
      user = create(:user)
      surgeon = create(:surgeon)
      procedure = create(:procedure)
      create(:pin, surgeon: surgeon, procedure: procedure, sensation: 5, satisfaction: 4)
      create(:pin, surgeon: surgeon, procedure: procedure, sensation: 5, satisfaction: 2)

      sign_in user
      get :show, id: surgeon.id

      expect(assigns(:rating_distributions)).to eq(
        sensation: { 5 => 2 },
        satisfaction: { 2 => 1, 4 => 1 }
      )
      expect(assigns(:rating_distributions_by_procedure)[procedure.id]).to eq(
        sensation: { 5 => 2 },
        satisfaction: { 2 => 1, 4 => 1 }
      )
      expect(assigns(:sensation_by_procedure)[procedure.id]).to eq(5.0)
      expect(assigns(:satisfaction_by_procedure)[procedure.id]).to eq(3.0)
    end

    it 'does not expose overall rating averages to anonymous users' do
      surgeon = create(:surgeon)

      get :show, id: surgeon.id

      expect(assigns(:overall_satisfaction)).to be_nil
      expect(assigns(:overall_sensation)).to be_nil
    end

    it 'loads the three latest published submissions for signed-in users' do
      user = create(:user)
      surgeon = create(:surgeon)
      procedure = create(:procedure)
      old_pin = create(:pin, surgeon: surgeon, procedure: procedure, state: 'published', updated_at: 3.days.ago)
      newest_pin = create(:pin, surgeon: surgeon, procedure: procedure, state: 'published', updated_at: 1.day.ago)
      create(:pin, surgeon: surgeon, procedure: procedure, state: 'pending', updated_at: Time.current)

      sign_in user
      get :show, id: surgeon.id

      expect(assigns(:latest_pins)).to eq([newest_pin, old_pin])
    end

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
