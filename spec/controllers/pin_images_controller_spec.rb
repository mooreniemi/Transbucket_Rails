require 'spec_helper'

describe PinImagesController, :type => :controller do
  before(:each) do
    allow(User).to receive(:find).and_return(build(:user))
    sign_in
  end
  describe 'POST #create' do
    it 'returns a valid pin on_image create' do
      image_attrs = attributes_for(:pin_image)

      expect{post :create, pin_image: image_attrs}.to change{PinImage.count}.by(1)
    end
  end
end
