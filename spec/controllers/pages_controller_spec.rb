require 'rails_helper'

describe PagesController, :type => :controller do
  render_views

  describe 'GET newsfeed' do
    it 'renders a static archive without fetching tumblr' do
      expect(URI).not_to receive(:open)

      get 'newsfeed'

      expect(response).to be_success
      expect(assigns(:newsfeed_entries).length).to eq(3)
      expect(response.body).to include('We cleaned up a set of procedure names')
      expect(response.body).to include('Procedure search now matches prefixes')
      expect(response.body).to include('The Discord community invite now points to a permanent link.')
    end
  end
end
