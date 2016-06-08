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

        attrs = build(:pin, :with_surgeon_and_procedure).attributes
        image_attrs = attributes_for(:pin_image)

        post(:create, {pin: attrs, pin_images: {"0" => image_attrs}})
        expect(response).to redirect_to(pin_url(assigns(:pin)))
      end

      it "refuses to create an invalid pin" do
        sign_in

        attrs = attributes_for(:pin, :invalid)
        image_attrs = attributes_for(:pin_image)

        post(:create, {pin: attrs, pin_images: {"0" => image_attrs}})
        expect(assigns(:form).errors).not_to be_empty
      end
    end
  end
end
