require 'rails_helper'

describe ProceduresController, :type => :controller do
  describe "#index" do
    it 'gives a list of procedures and their average sensation and satisfaction' do
      procedures = create_list(:procedure, 2)
      get :index
      expect(assigns(:procedures)).to eq(procedures)
      expect(response).to render_template(:index)
    end
    xit 'links procedures to queries for all pins of that procedure' do
    end
  end
  describe "#show" do
    xit 'shows a procedure detail page by id or friendly slug' do
    end
  end
end
