require 'rails_helper'

RSpec.describe CommentMailer do
  let(:user) { create(:user, :with_confirmation) }
  let(:pin) { create(:pin, user: user) }

  it 'localizes comment notifications and their links' do
    I18n.with_locale(:es) do
      mail = described_class.new_comment_email(user.id, pin.id)

      expect(mail.subject).to eq("Transbucket.com: Nuevo comentario en #{pin.id}")
      expect(mail.body.raw_source).to include('Hola')
      expect(mail.body.raw_source).to include('/es/pins/')
      expect(mail.body.raw_source).to include('Configuración')
    end
  end
end
