require 'spec_helper'

describe PinPresenter do
  let(:pins) { create_list(:pin, 3) }
  let(:user) { create(:user) }

  it 'returns pins' do
    presenter = PinPresenter.new({current_user: user})

    expect(presenter.all).to eq(pins.to_a.reverse)
  end

  it 'returns pins scoped by surgeon' do
    surgeon = create(:surgeon)

    pins.last.update_attributes(surgeon_id: surgeon.id)

    presenter = PinPresenter.new({current_user: user, surgeon: surgeon.id})

    expect(presenter.all.last).to eq(pins.last)
  end

  it 'returns pins scoped by procedure' do
    procedure = create(:procedure)

    pins.last.update_attributes(procedure_id: procedure.id)

    presenter = PinPresenter.new({current_user: user, procedure: procedure.id})

    expect(presenter.all.last).to eq(pins.last)
  end

  it 'returns pins scoped by user' do
    current_user = create(:user)

    user_id = pins.last.user_id

    presenter = PinPresenter.new({current_user: current_user, user: user_id})

    expect(presenter.all.last).to eq(pins.last)
  end
end