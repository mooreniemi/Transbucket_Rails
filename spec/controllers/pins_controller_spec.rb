require 'rails_helper'

describe PinsController, :type => :controller do
  render_views

  describe 'GET #index' do
    it "blocks unauthenticated access" do
      get :index, params: { locale: 'en' }

      expect(response).to redirect_to(new_user_session_path(locale: 'en'))
    end
  end

  context "when signed in" do
    let (:user) { create(:user) }

    before(:each) do
      sign_in(user)
    end

    describe "GET #index" do
      it "allows authenticated access" do
        get :index, params: { locale: 'en' }

        expect(response).to be_success
      end

      it 'passes the signed-in user safe-mode preference to pin cards' do
        user.preference.update_attributes!(safe_mode: true)
        create(:pin, user: user)

        get :index, params: { locale: 'en' }

        expect(assigns(:safe_mode)).to eq(true)
        expect(response.body).to include('safe-blur')
        expect(response.body).to include('data-safe-reveal')
        expect(response.body).to include('data-safe-hide')
      end

      it 'passes the safe-mode preference to the pin page too' do
        user.preference.update_attributes!(safe_mode: true)
        pin = create(:pin, user: user)

        get :show, params: { id: pin.id, locale: 'en' }

        expect(assigns(:safe_mode)).to eq(true)
      end

      it 'shows pin images when the signed-in user has not enabled safe mode' do
        user.preference.update_attributes!(safe_mode: false)
        create(:pin, user: user)

        get :index, params: { locale: 'en' }

        expect(assigns(:safe_mode)).to eq(false)
        expect(response.body).not_to include('safe-blur')
        expect(response.body).not_to include('data-safe-reveal')
      end

      it "renders the authenticated index with a locale and user filter" do
        get :index, params: { locale: 'ja', user: user.id }

        expect(response).to be_success
        expect(response.body).to include('最近の投稿')
      end

      it 'shows a For You tab for MTF and FTM users' do
        user.update_attributes!(gender: create(:gender, name: 'MTF'))

        get :index, params: { locale: 'en' }

        expect(response.body).to include('Recent')
        expect(response.body).to include('For You')
        expect(response.body).to include('feed=for_you')
      end

      it 'does not show a For You tab when the profile cannot define one' do
        user.update_attributes!(gender: create(:gender, name: 'GenderQueer'))

        get :index, params: { locale: 'en' }

        expect(response.body).not_to include('For You')
      end

      it 'groups moderator tools under an accessible moderator menu' do
        user.update_attributes!(admin: true)

        get :index, params: { locale: 'en' }

        expect(response.body).to include('title="Moderation tools"')
        expect(response.body).to include('Moderation queue')
        expect(response.body).to include('Community trust')
        expect(response.body).to include('fa-shield')
      end

      it 'labels the personalized feed For You' do
        user.update_attributes!(gender: create(:gender, name: 'MTF'))

        get :index, params: { feed: 'for_you', locale: 'en' }

        expect(response.body).to include('<h1 class="feed-title">For You</h1>')
        expect(response.body).not_to include('<h1>Recent Submissions</h1>')
      end

      it 'renders each published Pin card with its own impression and open telemetry target' do
        first_pin = create(:pin, user: user)
        second_pin = create(:pin, user: user)

        get :index, params: { locale: 'en' }

        [first_pin, second_pin].each do |pin|
          card = response.body[/<div class="item" data-pin-id="#{pin.id}".*?<\/div>\s*<\/div>/m]
          expect(card).to include('data-event-type="impression"')
          expect(card).to include("data-content-id=\"#{pin.id}\"")
          expect(card).to include('data-content-event-open="true"')
          expect(card).to include("href=\"#{pin_path(pin)}\"")
        end
      end
    end

    describe 'GET #admin' do
      it 'forbids members without a Moderator role' do
        get :admin, params: { locale: 'en' }

        expect(response).to have_http_status(:forbidden)
      end

      it 'allows a Moderator to view the queue but not the trust console link' do
        user.grant_trust!('moderator', granted_by: create(:user, admin: true))

        get :index, params: { locale: 'en' }
        expect(response.body).to include('Moderation queue')
        expect(response.body).not_to include('Community trust')

        get :admin, params: { locale: 'en' }
        expect(response).to be_success
      end

      it 'renders current flaggers and lifetime moderation counts' do
        admin = create(:user, admin: true)
        pin = create(:pin)
        flaggers = create_list(:user, 3)
        flaggers.each { |flagger| Flag.new(flagger, pin).flag_on }
        sign_in(admin)

      get :admin, params: { locale: 'en' }

        expect(response).to be_success
        expect(response.body).to include('Top flaggers (lifetime)')
        expect(response.body).to include('Most flagged (lifetime)')
        expect(response.body).to include('<td>2</td>')
        expect(response.body).to include('<td>3</td>')
        expect(response.body).to include(flaggers.first.username)
      end
    end

    describe 'GET #show' do
      it "retrieves pin for view" do

        pin = create(:pin, user: user)
        get :show, params: { id: pin.id, locale: 'en' }

        expect(response).to be_success
      end

      it "renders localized labels on a pin page" do
        pin = create(:pin, user: user)
        get :show, params: { id: pin.id, locale: 'ja' }

        expect(response).to be_success
        expect(response.body).to include('外科医')
        expect(response.body).to include('手術')
      end

      it 'preserves line breaks in the in-depth experience' do
        pin = create(:pin, user: user, details: "First paragraph\nSecond paragraph")

      get :show, params: { id: pin.id, locale: 'en' }

        expect(response.body).to match(/First paragraph\s*<br/)
        expect(response.body).to include('Second paragraph')
      end

      it 'links the procedure label to the procedure page' do
        pin = create(:pin, user: user)
      get :show, params: { id: pin.id, locale: 'en' }

        expect(response.body).to include("href=\"#{procedure_path(pin.procedure)}\"")
        expect(response.body).not_to include("procedure=#{pin.procedure.id}")
      end
    end

    describe 'GET #edit' do
      it "retrieves pin for edit view" do
        create(:surgeon, id: 911)

        pin = create(:pin, user: user)
        get :edit, params: { id: pin.id, locale: 'en' }

        expect(response).to be_success
      end

      it 'allows an admin to edit another user\'s pin' do
        admin = create(:user, admin: true)
        pin = create(:pin, user: create(:user))

        sign_in(admin)
        get :edit, params: { id: pin.id, locale: 'en' }

        expect(response).to be_success
      end
    end

    describe 'cached pin actions' do
      around do |example|
        previous_setting = ActionController::Base.perform_caching
        ActionController::Base.perform_caching = true
        Rails.cache.clear
        example.run
      ensure
        Rails.cache.clear
        ActionController::Base.perform_caching = previous_setting
      end

      it 'does not show an edit link cached for the owner to another user' do
        owner = create(:user)
        viewer = create(:user)
        pin = create(:pin, user: owner)

        sign_in(owner)
        get :show, params: { id: pin.id, locale: 'en' }
        expect(response.body).to include(edit_pin_path(pin))

        sign_in(viewer)
        get :show, params: { id: pin.id, locale: 'en' }
        expect(response.body).not_to include(edit_pin_path(pin))
      end
    end

    describe 'GET #new' do
      it 'renders the locale-specific TinyMCE language asset' do
        get :new, params: { locale: 'es' }

        expect(response).to be_success
        expect(response.body).to include('language: "es"')
      end
    end

    describe 'GET #complication_suggestions' do
      it 'returns existing Pin complication tags matching the term' do
        pin = create(:pin, user: user)
        pin.complication_list = 'hematoma, infection'
        pin.save!

      get :complication_suggestions, params: { term: 'hema', format: :json, locale: 'en' }

        expect(response).to be_success
        expect(JSON.parse(response.body)).to eq(['hematoma'])
      end
    end

    describe 'POST #create' do
      it 'returns a valid pin on create' do
        surgeon = attributes_for(:surgeon)
        procedure = attributes_for(:procedure)
        attrs = attributes_for(:pin).merge({"surgeon_attributes" => surgeon, "procedure_attributes" => procedure})
        image_attrs = attributes_for(:pin_image)

        post :create, params: { pin: attrs, pin_images: {"0" => image_attrs} }
        expect(response).to redirect_to(pin_url(assigns(:pin)))
      end

      it 'keeps the selected locale after creating a pin' do
        surgeon = attributes_for(:surgeon)
        procedure = attributes_for(:procedure)
        attrs = attributes_for(:pin).merge("surgeon_attributes" => surgeon, "procedure_attributes" => procedure)
        image_attrs = attributes_for(:pin_image)

        post :create, params: { pin: attrs, pin_images: { "0" => image_attrs }, locale: 'es' }

        expect(response).to redirect_to(pin_url(assigns(:pin), locale: 'es'))
      end

      it "refuses to create an invalid pin" do
        attrs = attributes_for(:pin, :invalid)
        image_attrs = attributes_for(:pin_image)

        post :create, params: { pin: attrs, pin_images: {"0" => image_attrs} }
        expect(assigns(:form).errors).not_to be_empty
      end
    end

    describe 'PUT #update' do
      def clear_attrs(attrs)
        attrs.reject do |k,v|
          case k
          when 'id', 'updated_at', 'created_at',
               'procedure_attributes', 'procedure_id', 'surgeon_attributes', 'surgeon_id'; true
          else false
          end
        end
      end

      it 'updates an existing pin' do
        pin = create(:pin, :with_surgeon_and_procedure, :real_pin_images, user: user)
        old_surgeon_id = pin.surgeon.id
        old_procedure_id = pin.procedure.id

        surgeon = attributes_for(:surgeon)
        procedure = attributes_for(:procedure)
        updated_attrs = build(:pin, user: user).attributes.merge({"surgeon_attributes" => surgeon, "procedure_attributes" => procedure})
        # Rails 5 preserves an empty rich-text form field as an empty string;
        # Rails 4's parameter handling represented the same value as nil.
        updated_attrs["details"] = ""

        put :update, params: { :id => pin.id, :pin => updated_attrs }

        pin.reload
        expect(response).to redirect_to(pin_url(assigns(:pin)))

        pin_attrs = clear_attrs(pin.attributes)
        updated_attrs = clear_attrs(updated_attrs)

        expect(pin_attrs).to eq(updated_attrs)
        expect(pin.surgeon.id).to_not eq(old_surgeon_id)
        expect(pin.procedure.id).to_not eq(old_procedure_id)
        expect(pin.surgeon.url).to eq(surgeon[:url])
        expect(pin.procedure.name).to eq(procedure[:name])
      end

      it 'allows an admin to update another user\'s pin' do
        admin = create(:user, admin: true)
        pin = create(:pin, :with_surgeon_and_procedure, :real_pin_images, user: create(:user))

        sign_in(admin)
        put :update, params: { id: pin.id, pin: {
          cost: 123,
          surgeon_attributes: { id: pin.surgeon.id },
          procedure_attributes: { id: pin.procedure.id }
        } }

        expect(response).to redirect_to(pin_url(pin))
        expect(pin.reload.cost).to eq(123)
      end
    end

    describe "DELETE #destroy" do
      it "deletes a pin and redirects to pins index" do
        pin = create(:pin, user: user)

        delete :destroy, params: { :id => pin.id }
        expect(response).to redirect_to(pins_url)
      end

      it 'allows a Moderator to remove another member’s queued pin' do
        moderator = create(:user)
        moderator.grant_trust!('moderator', granted_by: create(:user, admin: true))
        pin = create(:pin, user: create(:user))
        sign_in(moderator)

        delete :destroy, params: { id: pin.id, locale: 'en' }

        expect(response).to redirect_to(pins_url)
        expect(Pin.find_by(id: pin.id)).to be_nil
      end
    end
  end

  context "when signed in as a different user" do
    let (:users) { create_list(:user, 2) }
    let (:pin) { create(:pin, user: users.last)}

    before(:each) do
      sign_in(users.first)
    end

    describe "GET #edit" do
      it "is forbidden to edit" do
        get :edit, params: { id: pin.id, locale: 'en' }

        expect(response).to be_forbidden
      end
    end

    describe "PUT #update" do
      it "is forbidden to update" do
        updated_attrs = build(:pin).attributes

        put :update, params: { :id => pin.id, :pin => updated_attrs }

        expect(response).to be_forbidden
      end
    end

    describe "DELETE #destroy" do
      it "is forbidden to destroy" do
        delete :destroy, params: { :id => pin.id }

        expect(response).to be_forbidden
      end
    end
  end
end
