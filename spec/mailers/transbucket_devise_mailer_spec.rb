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

  it 'provides the Swedish unlock translations for the configured mailer' do
    expect(I18n.t('devise.mailer.unlock_instructions.subject', locale: :sv)).to eq('Instruktioner för upplåsning')
    expect(I18n.t('devise.mailer.unlock_instructions.action', locale: :sv)).to eq('Lås upp mitt konto')
  end

  it 'renders password-change notifications in the requested locale' do
    mail = described_class.password_change(user, locale: :sv)

    expect(mail.subject).to eq('Ditt lösenord har ändrats')
    expect(mail.body.raw_source).to include('Vi kontaktar dig för att meddela att ditt lösenord har ändrats.')
  end
end
