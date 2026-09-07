require 'rails_helper'

describe PagesController, :type => :controller do
  describe 'GET newsfeed' do
    it 'fetches and trims the tumblr feed' do
      rss = double('rss', items: %w[a b c d])
      allow(URI).to receive(:open).and_return(StringIO.new('<rss></rss>'))
      allow(SimpleRSS).to receive(:parse).and_return(rss)

      get 'newsfeed'

      expect(assigns(:rss)).to eq(%w[a b c])
    end
  end
end
