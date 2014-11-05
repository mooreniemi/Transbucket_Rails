require 'spec_helper'

describe PinPresenter do
  let(:pins) { create_list(:pin, 3) }

  it 'returns pins' do
    presenter = PinPresenter.new({})

    expect(presenter.all).to eq(pins.to_a.reverse)
  end

  it 'returns pins scoped by surgeon' do
    surgeon = create(:surgeon)

    pins.last.update_attributes(surgeon_id: surgeon.id)

    presenter = PinPresenter.new({surgeon: surgeon.id})

    expect(presenter.all.last).to eq(pins.last)
  end

  it 'returns pins scoped by procedure' do
    procedure = create(:procedure)

    pins.last.update_attributes(procedure_id: procedure.id)

    presenter = PinPresenter.new({procedure: procedure.id})

    expect(presenter.all.last).to eq(pins.last)
  end

  it 'returns pins scoped by user' do

    user_id = pins.last.user_id

    presenter = PinPresenter.new({user: user_id})

    expect(presenter.all.last).to eq(pins.last)
  end
end