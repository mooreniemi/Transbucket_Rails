require 'rails_helper'

RSpec.describe SurgeonsController, :type => :controller do
  describe "#index" do
    it 'gives a list of surgeons' do
      surgeons = create_list(:surgeon, 2)
      get :index
      expect(assigns(:surgeons)).to match_array(surgeons)
      expect(response).to render_template(:index)
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
    end
  end
end
