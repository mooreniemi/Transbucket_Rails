require 'rails_helper'
require 'cgi'

RSpec.describe Devise::Mailer do
  let(:user) { create(:user, :with_confirmation) }

  it 'includes the reminder copy when confirmation_reminder is set' do
    user.confirmation_reminder = true
    mail = described_class.confirmation_instructions(user, 'test-token')

    expect(mail.body.raw_source).to include(
      CGI.escapeHTML(I18n.t('devise.mailer.confirmation_instructions.reminder_notice'))
    )
    expect(mail.body.raw_source).to include(
      CGI.escapeHTML(I18n.t('devise.mailer.confirmation_instructions.reminder_help'))
    )
  end

  it 'omits the reminder copy for a normal (non-reminder) confirmation email' do
    mail = described_class.confirmation_instructions(user, 'test-token')

    expect(mail.body.raw_source).not_to include(
      CGI.escapeHTML(I18n.t('devise.mailer.confirmation_instructions.reminder_notice'))
    )
  end
end
