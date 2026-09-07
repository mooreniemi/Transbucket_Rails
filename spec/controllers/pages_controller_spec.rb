require 'rails_helper'

describe PagesController, :type => :controller do
  render_views

  describe 'GET newsfeed' do
    it 'renders the reset page without fetching tumblr' do
      expect(URI).not_to receive(:open)

      get 'newsfeed'

      expect(response).to be_success
      expect(response.body).to include('The newsfeed has been reset and will start fresh today.')
    end
  end
end
