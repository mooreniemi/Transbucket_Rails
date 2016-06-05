require 'rails_helper'

describe PinsController, :type => :controller do
  describe 'GET #index' do
    it "blocks unauthenticated access" do
      get :index

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when signed in" do
    before(:each) do
      allow(User).to receive(:find).and_return(build(:user))
      sign_in
    end

    describe "GET #index" do
      it "allows authenticated access" do
        get :index

        expect(response).to be_success
      end
    end

    describe 'GET #show' do
      it "retrieves pin for view" do

        pin = create(:pin)
        get :show, id: pin.id

        expect(response).to be_success
      end
    end

    describe 'GET #edit' do
      it "retrieves pin for edit view" do

        pin = create(:pin)
        get :edit, id: pin.id

        expect(response).to be_success
      end
    end

    describe 'POST #create' do
      it 'returns a valid pin on create' do
        sign_in

        attrs = attributes_for(:pin)
        image_attrs = attributes_for(:pin_image)
        attrs.merge!(pin_images_attributes: {pin_image: image_attrs})

        allow(PinCreatorService).to receive(:new).and_return(service = double('service'))

        allow(service).to receive(:create).and_return(pin = create(:pin))

        post :create, pin: attrs
      end
    end
  end
end
