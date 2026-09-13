require 'rails_helper'

describe PinImagesController, type: :controller do
  before(:each) do
    allow(User).to receive(:find).and_return(build(:user))
    sign_in
  end
  # Rack::Test::UploadedFile (not ActionDispatch::Http::UploadedFile, which
  # models a real server-received upload) is what controller-spec params
  # need: Rails 5's request encoding recognizes it and passes the file
  # through, where it silently stringified an ActionDispatch::Http::
  # UploadedFile instead.
  let(:test_photo) do
    Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/cat.png", 'image/png')
  end
  describe 'POST #create' do
    it 'returns a valid pin on_image create' do
      params = {
        "0"=> {photo: test_photo, caption: attributes_for(:pin_image)[:caption]}
      }

      caption = params["0"][:caption]

      expect{post :create, params: { pin_images: params }}.to change{PinImage.count}.by(1)
      expect(PinImage.last.caption).to eq(caption)
    end
  end
end
