require 'rails_helper'

# Submitting or editing a pin records a server-side content event, so the
# submission funnel (impression -> open -> view -> submission) can be read from
# content_events alone. Tracking must never get in the way of the submission.
describe PinsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  def valid_pin_params
    attrs = attributes_for(:pin).merge(
      'surgeon_attributes' => attributes_for(:surgeon),
      'procedure_attributes' => attributes_for(:procedure)
    )
    { pin: attrs, pin_images: { '0' => attributes_for(:pin_image) }, locale: 'es' }
  end

  def submission_events
    ContentEvent.where(source: 'server', event_type: %w[submission_created submission_updated])
  end

  describe 'POST #create' do
    it 'records one submission_created event for the new pin' do
      post :create, params: valid_pin_params

      pin = assigns(:pin)
      expect(pin).to be_persisted
      expect(submission_events.count).to eq(1)
      expect(submission_events.last).to have_attributes(
        event_type: 'submission_created', content_type: 'Pin', content_id: pin.id, user_id: user.id, locale: 'es'
      )
    end

    it 'records nothing when the pin is invalid' do
      post :create, params: { pin: attributes_for(:pin, :invalid), pin_images: { '0' => attributes_for(:pin_image) } }

      expect(assigns(:form).errors).not_to be_empty
      expect(submission_events.count).to eq(0)
    end

    it 'still saves the pin and redirects when recording the event fails' do
      allow(ContentEvent).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'canceling statement due to statement timeout')

      expect { post :create, params: valid_pin_params }.to change(Pin, :count).by(1)
      expect(response).to redirect_to(pin_url(assigns(:pin), locale: 'es'))
    end
  end

  describe 'PUT #update' do
    let!(:pin) { create(:pin, :with_surgeon_and_procedure, :real_pin_images, user: user) }

    def update_params(cost)
      { id: pin.id, locale: 'en', pin: {
        cost: cost,
        surgeon_attributes: { id: pin.surgeon.id },
        procedure_attributes: { id: pin.procedure.id }
      } }
    end

    it 'records a submission_updated event for the edited pin' do
      put :update, params: update_params(456)

      expect(pin.reload.cost).to eq(456)
      expect(submission_events.count).to eq(1)
      expect(submission_events.last).to have_attributes(event_type: 'submission_updated', content_id: pin.id, user_id: user.id)
    end

    it 'records nothing when someone else is refused the edit' do
      sign_in(create(:user))

      put :update, params: update_params(789)

      expect(response).to be_forbidden
      expect(submission_events.count).to eq(0)
    end

    it 'still saves the edit when recording the event fails' do
      allow(ContentEvent).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, 'canceling statement due to statement timeout')

      put :update, params: update_params(321)

      expect(pin.reload.cost).to eq(321)
      expect(response).to redirect_to(pin_url(pin, locale: 'en'))
    end
  end
end
