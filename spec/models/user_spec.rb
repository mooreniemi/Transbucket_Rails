require 'rails_helper'

describe User, '.find_first_by_auth_conditions' do
  let!(:user) { create(:user) }

  it 'finds a user by username, case-insensitively' do
    found = User.find_first_by_auth_conditions(login: user.username.upcase)
    expect(found).to eq(user)
  end

  it 'finds a user by email, case-insensitively' do
    found = User.find_first_by_auth_conditions(login: user.email.upcase)
    expect(found).to eq(user)
  end

  it 'returns nil when neither username nor email match anyone' do
    found = User.find_first_by_auth_conditions(login: 'definitely-not-a-real-login')
    expect(found).to be_nil
  end

  it 'does not cross-match one user\'s username against another user\'s email' do
    other = create(:user)
    found = User.find_first_by_auth_conditions(login: other.email)
    expect(found).to eq(other)
  end

  it 'falls back to a plain lookup when no :login condition is given' do
    found = User.find_first_by_auth_conditions(id: user.id)
    expect(found).to eq(user)
  end
end
