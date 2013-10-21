require 'spec_helper'

describe PinsController do
	describe 'GET #index' do
			it "populates an array of pins" do
				pin = FactoryGirl.create(:pin)
				get :index
				expect(assigns(:pins)).to match_array [pin]
			end

			it "renders the :index view" do
				get :index
				expect(response).to render_template :index
			end
	end

	describe 'GET #show' do
			it "assigns the requested pin to @pin" do
				pin = FactoryGirl.create(:pin)
				get :show, id: pin
				expect(assigns(:pin)).to eq pin
			end

			it "renders the :show template" do
				pin = pin(:pin)
				get :show, id: pin
				expect(response).to render_template :show
			end
	end

	describe 'GET #new' do
			it "assigns a new Pin to @pin" do
				get :new
				expect(assigns(:pin)).to be_a_new(Pin)
			end

			it "renders the :new template" do
				get :new
				expect(response).to render_template :new
			end
	end

	describe 'GET #edit' do
			it "assigns the requested pin to @pin" do
				pin = FactoryGirl.create(:pin)
				get :edit, id: pin
				expect(assigns(:pin)).to eq pin
			end

			it "renders the :edit template" do
				pin = create(:pin)
				get :edit, id: pin
				expect(response).to render_template :edit
			end
	end

	describe 'POST #create' do
		context "with valid attributes" do
			it "saves the new pin in the database" do
				expect{
					post :create, pin: attributes_for(:pin)
				}.to change(Pin, :count).by(1)
			end

			it "redirects to the pin page" do
				post :create, pin: attributes_for(:pin)
				expect(response).to render_template :show
			end
		end

		context "with invalid attributes" do
			it "does not save the new pin in the database" do
				expect{
					post :create,
					pin: attributes_for(:invalid_pin)
				}.to_not change(Pin, :count)
			end

			it "re-renders the :new template" do
				post :create,
				pin: attributes_for(:invalid_pin)
				expect(response).to render_template :new
			end
		end
	end

	describe 'PUT #update' do
		before :each do
			@pin = create(:pin, description: "Meow meow", surgeon: "Dr. Meow", procedure: "Meowch", user_id: "1323")
		end

		it "locates the requested @pin" do
			put :update, id: @pin, pin: attributes_for(:pin)
			expect(assigns(:pin)).to eq(@pin)
		end

		context "with valid attributes" do
			it "updates the pin in the database"
			it "rediects to the message"
		end

		context "with invalid attributes" do
			it "does not update the message"
			it "re-renders the #edit template"
		end
	end

	describe 'DELETE #destroy' do
		it "deletes the message from the database"
		it "redirects to the home page"
	end
end
