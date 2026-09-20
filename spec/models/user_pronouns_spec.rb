require 'rails_helper'

describe User, 'pronouns' do
  let(:user) { build(:user) }

  it 'is valid without pronouns, so existing users keep working' do
    user.pronouns = nil
    expect(user).to be_valid
  end

  it 'accepts every preset' do
    User::PRONOUN_PRESETS.each do |preset|
      user.pronouns = preset
      expect(user).to be_valid, "#{preset} should be valid"
    end
  end

  it 'accepts two to four slash-separated words' do
    ['xe/xem', 'she/her/hers', 'they/them/theirs/themself', "o'ne/ver-y"].each do |value|
      user.pronouns = value
      expect(user).to be_valid, "#{value} should be valid"
    end
  end

  it 'rejects anything that is not in the x/y shape' do
    ['they', 'they them', '/them', 'they/', 'a/b/c/d/e', 'they//them', 'http://x.co', 'they/them!', '1/2', ('a' * 41)].each do |value|
      user.pronouns = value
      expect(user).not_to be_valid, "#{value.inspect} should be invalid"
      expect(user.errors[:base]).to include(I18n.t('public.auth.pronouns_invalid'))
    end
  end

  it 'tidies case and spacing around slashes' do
    user.pronouns = '  She / Her  '
    user.valid?
    expect(user.pronouns).to eq('she/her')
  end

  it 'takes the typed text when Other is chosen' do
    user.pronouns = User::CUSTOM_PRONOUNS
    user.pronouns_custom = 'Fae / Faer'
    expect(user).to be_valid
    expect(user.pronouns).to eq('fae/faer')
  end

  it 'treats Other with nothing typed as not chosen' do
    user.pronouns = User::CUSTOM_PRONOUNS
    user.pronouns_custom = ' '
    expect(user).to be_valid
    expect(user.pronouns).to be_nil
  end

  it 'treats the blank default option as not chosen' do
    user.pronouns = ''
    user.valid?
    expect(user.pronouns).to be_nil
  end

  it 'accepts other scripts and the full-width slash an IME produces' do
    user.pronouns = '彼／彼の'
    expect(user).to be_valid
    expect(user.pronouns).to eq('彼/彼の')
    user.pronouns = 'она/её'
    expect(user).to be_valid
  end
end
