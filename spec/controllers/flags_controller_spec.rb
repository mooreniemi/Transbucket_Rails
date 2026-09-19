require 'rails_helper'

describe FlagsController, type: :controller do
  render_views

  it 'records an unflag moderation event before removing active flags' do
    moderator = create(:user)
    flagger = create(:user)
    pin = create(:pin)
    pin.downvote_from(flagger)
    pin.review!
    sign_in(moderator)

    xhr :delete, :destroy, pin_id: pin.id

    expect(response).to be_success
    expect(ModerationEvent.where(action: 'unflag', content_type: 'Pin', content_id: pin.id).count).to eq(1)
    expect(pin.votes.down.count).to eq(0)
  end
end
