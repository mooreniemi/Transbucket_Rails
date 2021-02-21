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
    xit 'shows a surgeon detail page by id or friendly slug' do
    end
  end
end
