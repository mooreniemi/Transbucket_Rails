require 'rails_helper'

# These endpoints used to be open to anyone. An anonymous request could upload
# images and delete or re-caption any post's photos just by knowing the ids.
describe PinImagesController, type: :controller do
  let(:owner) { create(:user, :with_confirmation) }
  let(:pin) { create(:pin, user: owner, pin_images: build_list(:pin_image, 2)) }
  let(:image) { pin.pin_images.first }
  let(:stranger) { create(:user, :with_confirmation) }
  let(:upload) { { '0' => { photo: fixture_file_upload('cat.jpg', 'image/jpeg'), caption: 'new' } } }

  context 'when nobody is signed in' do
    it 'refuses to accept an upload' do
      expect { post :create, pin_images: upload, format: :json }.not_to change { PinImage.count }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'refuses to delete a photo' do
      xhr :delete, :destroy, pin_id: pin.id, id: image.id, format: :js

      expect(response).to have_http_status(:unauthorized)
      expect(PinImage.exists?(image.id)).to eq(true)
    end

    it 'refuses to change a caption' do
      put :update, id: image.id, caption: 'hijacked', format: :json

      expect(response).to have_http_status(:unauthorized)
      expect(image.reload.caption).not_to eq('hijacked')
    end

    it 'refuses to list a post\'s photos' do
      get :index, pin_id: pin.id, format: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when signed in as someone other than the post\'s author' do
    before { sign_in(stranger) }

    it 'cannot delete their photo' do
      xhr :delete, :destroy, pin_id: pin.id, id: image.id, format: :js

      expect(response).to have_http_status(:forbidden)
      expect(PinImage.exists?(image.id)).to eq(true)
    end

    it 'cannot change their caption' do
      put :update, id: image.id, caption: 'hijacked', format: :json

      expect(response).to have_http_status(:forbidden)
      expect(image.reload.caption).not_to eq('hijacked')
    end

    it 'can still upload photos for their own post' do
      expect { post :create, pin_images: upload, format: :json }.to change { PinImage.count }.by(1)
      expect(response).to have_http_status(:ok)
    end

    it 'can caption a photo they just uploaded and have not attached to a post yet' do
      fresh = PinImage.create!(photo: fixture_file_upload('cat.jpg', 'image/jpeg'), caption: 'before')

      put :update, id: fresh.id, caption: 'after', format: :json

      expect(response).to have_http_status(:ok)
      expect(fresh.reload.caption).to eq('after')
    end
  end

  context 'when signed in as the post\'s author' do
    before { sign_in(owner) }

    it 'can delete their photo' do
      xhr :delete, :destroy, pin_id: pin.id, id: image.id, format: :js

      expect(response).to be_success
      expect(PinImage.exists?(image.id)).to eq(false)
    end

    it 'can change their caption, and gets a proper JSON answer' do
      put :update, id: image.id, caption: 'mine', format: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq('id' => image.id, 'caption' => 'mine')
      expect(image.reload.caption).to eq('mine')
    end

    it 'cannot reach a photo through a different post\'s id' do
      other_pin = create(:pin, user: owner, pin_images: build_list(:pin_image, 1))

      expect { xhr :delete, :destroy, pin_id: other_pin.id, id: image.id, format: :js }.to raise_error(ActiveRecord::RecordNotFound)
      expect(PinImage.exists?(image.id)).to eq(true)
    end
  end

  context 'when signed in as an admin or a moderator' do
    it 'lets an admin change and delete anyone\'s photos' do
      sign_in(create(:user, :with_confirmation, admin: true))

      put :update, id: image.id, caption: 'admin edit', format: :json
      expect(response).to have_http_status(:ok)

      xhr :delete, :destroy, pin_id: pin.id, id: image.id, format: :js
      expect(PinImage.exists?(image.id)).to eq(false)
    end

    it 'lets a moderator remove a photo but not rewrite its caption' do
      moderator = create(:user, :with_confirmation)
      moderator.grant_trust!('moderator', granted_by: create(:user, admin: true))
      sign_in(moderator)

      put :update, id: image.id, caption: 'nope', format: :json
      expect(response).to have_http_status(:forbidden)

      xhr :delete, :destroy, pin_id: pin.id, id: image.id, format: :js
      expect(PinImage.exists?(image.id)).to eq(false)
    end
  end
end
