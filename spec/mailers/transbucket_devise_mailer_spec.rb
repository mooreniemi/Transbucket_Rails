require 'rails_helper'

RSpec.describe TransbucketDeviseMailer do
  let(:user) { create(:user, :with_confirmation) }

  it 'tags a reminder email with a confirmation_reminder SendGrid category' do
    user.confirmation_reminder = true
    mail = described_class.confirmation_instructions(user, 'test-token')

    category = JSON.parse(mail['X-SMTPAPI'].value)['category']
    expect(category).to eq(['confirmation_reminder'])
  end

  it 'does not tag a normal (non-reminder) confirmation email' do
    mail = described_class.confirmation_instructions(user, 'test-token')

    expect(mail['X-SMTPAPI']).to be_nil
  end

  it 'renders confirmation instructions in the requested locale' do
    mail = described_class.confirmation_instructions(user, 'test-token', locale: :sv)

    expect(mail.subject).to eq('Bekräftelseinstruktioner')
    expect(mail.body.raw_source).to include('Bekräfta mitt konto')
    expect(mail.body.raw_source).to include('/sv/users/confirmation')
  end

  it 'renders password reset instructions in the requested locale' do
    mail = described_class.reset_password_instructions(user, 'test-token', locale: :sv)

    expect(mail.subject).to eq('Instruktioner för återställning av lösenord')
    expect(mail.body.raw_source).to include('Ändra mitt lösenord')
  end
end
