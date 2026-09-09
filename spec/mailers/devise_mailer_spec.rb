require 'rails_helper'

RSpec.describe Devise::Mailer do
  let(:user) { create(:user, :with_confirmation) }

  it 'localizes confirmation instructions and keeps the locale in the link' do
    I18n.with_locale(:es) do
      mail = described_class.confirmation_instructions(user, 'test-token')

      expect(mail.subject).to eq('Instrucciones de confirmación')
      expect(mail.body.raw_source).to include('Hola')
      expect(mail.body.raw_source).to include('Confirmar mi cuenta')
      expect(mail.body.raw_source).to include('/es/users/confirmation')
    end
  end
end
