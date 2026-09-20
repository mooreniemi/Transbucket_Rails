require 'rails_helper'

describe FlagsController, type: :controller do
  render_views

  it 'records an unflag moderation event before removing active flags' do
    moderator = create(:user)
    moderator.grant_trust!('moderator', granted_by: create(:user, admin: true))
    flagger = create(:user)
    pin = create(:pin)
    pin.downvote_from(flagger)
    pin.review!
    sign_in(moderator)

    delete :destroy, params: { pin_id: pin.id }, xhr: true

    expect(response).to be_success
    expect(ModerationEvent.where(action: 'unflag', content_type: 'Pin', content_id: pin.id).count).to eq(1)
    expect(pin.votes.down.count).to eq(0)
  end

  it 'forbids a member from clearing another member’s flags' do
    member = create(:user)
    pin = create(:pin)
    sign_in(member)

    delete :destroy, params: { pin_id: pin.id }, xhr: true

    expect(response).to have_http_status(:forbidden)
  end
end
