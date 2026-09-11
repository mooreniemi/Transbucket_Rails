require 'rails_helper'

describe ProcedureTranslation do
  it 'normalizes names and only permits supported locales' do
    procedure = create(:procedure, name: 'double incision')
    translation = procedure.translations.create!(locale: 'es', name: '  Doble Incisión  ')

    expect(translation.name).to eq('Doble Incisión')
    expect {
      procedure.translations.create!(locale: 'xx', name: 'unknown')
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'allows one translation per procedure and locale' do
    procedure = create(:procedure, name: 'double incision')
    procedure.translations.create!(locale: 'es', name: 'doble incisión')

    expect {
      procedure.translations.create!(locale: 'es', name: 'incisión doble')
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
