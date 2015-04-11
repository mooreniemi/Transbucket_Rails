require 'spec_helper'

describe PinImagesController, type: :controller do
  before(:each) do
    allow(User).to receive(:find).and_return(build(:user))
    sign_in
  end
  let(:test_photo) do
    ActionDispatch::Http::UploadedFile.new(
      {
        :filename => 'cat.png',
        :type => 'image/png',
        :tempfile => File.new("#{Rails.root}/spec/support/cat.png")
      }
    )
  end
  describe 'POST #create' do
    it 'returns a valid pin on_image create' do
      params = {
        "0"=> {photo: test_photo, caption: attributes_for(:pin_image)[:caption]}
      }

      caption = params["0"][:caption]

      expect{post :create, pin_images: params}.to change{PinImage.count}.by(1)
      expect(PinImage.last.caption).to eq(caption)
    end
  end
  context "actual params" do
    let(:params) do
      {"captions"=>
       {"0"=>"doodle"},
       "pin_images"=>
       {"0"=>test_photo},
       "action"=>"create",
       "controller"=>"pin_images"}
    end
    it "need to munge together captions and images" do
      post :create, params
      expect(response).to be_success
    end
  end
end
