require 'rails_helper'

describe UserTrustGrant do
  it 'uses Contributor as the default earned level and respects higher active grants' do
    user = create(:user)

    user.grant_trust!('contributor')
    expect(user.trust_tier).to eq('contributor')

    user.grant_trust!('moderator', granted_by: create(:user, admin: true), internal_note: 'Prototype review')
    expect(user.trust_tier).to eq('moderator')
  end

  it 'restores the next eligible level when a higher grant is revoked' do
    user = create(:user)
    user.grant_trust!('contributor')
    moderator = user.grant_trust!('moderator', granted_by: create(:user, admin: true))

    moderator.update_attributes!(revoked_at: Time.current)

    expect(user.reload.trust_tier).to eq('contributor')
  end

  it 'grants Contributor automatically when a published submission is created' do
    user = create(:user)

    create(:pin, user: user, state: 'published')

    grant = user.trust_grants.find_by(kind: 'contributor')
    expect(grant).to be_present
    expect(grant.source).to eq('automatic')
  end

  it 'grants Contributor when a pending submission is later published' do
    user = create(:user)
    pin = create(:pin, user: user, state: 'pending')

    expect(user.trust_grants.find_by(kind: 'contributor')).to be_nil

    pin.publish!

    expect(user.trust_grants.find_by(kind: 'contributor')).to be_present
  end

  it 'treats an active Moderator grant and admins as moderators' do
    moderator = create(:user)
    moderator.grant_trust!('moderator', granted_by: create(:user, admin: true))

    expect(moderator).to be_moderator
    expect(create(:user, admin: true)).to be_moderator
    expect(create(:user)).not_to be_moderator
  end
end
