require 'rails_helper'

describe PagesController, :type => :controller do
  render_views

  describe 'GET newsfeed' do
    it 'renders a static archive without fetching tumblr' do
      expect(URI).not_to receive(:open)

      get 'newsfeed'

      expect(response).to be_success
      expect(assigns(:newsfeed_entries).length).to eq(3)
      expect(response.body).to include('The newsfeed has been reset and will start fresh today.')
      expect(response.body).to include('September 7, 2026')
      expect(response.body).to include('Older Tumblr posts were condensed into a short archive.')
    end
  end
end
