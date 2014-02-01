require 'spec_helper'

describe PinsController do
	describe 'GET #index' do
    it "blocks unauthenticated access" do
       sign_in nil

       get :index

       response.should redirect_to(new_user_session_path)
     end

     it "allows authenticated access" do
       sign_in

       get :index

       response.should be_success
     end
	end

	describe 'GET #show' do
    it "retrieves pin for view" do
      sign_in

      pin = create(:pin)
      get :show, id: pin.id

      response.should be_success
    end
	end

	describe 'GET #edit' do
    it "retrieves pin for edit view" do
      sign_in

      pin = create(:pin)
      get :edit, id: pin.id

      response.should be_success
    end
	end

	describe 'POST #create' do
		it 'returns a valid pin on create' do
      sign_in

      attrs = attributes_for(:pin)
      image_attrs = attributes_for(:pin_image)
      attrs.merge!(pin_images_attributes: {pin_image: image_attrs})

      PinCreatorService.stub(:new).and_return(service = double('service'))

      service.stub(:create).and_return(pin = create(:pin))

      post :create, pin: attrs
    end
	end
end
