require 'spec_helper'

describe PinPresenter do
  it 'returns pins' do
    Pin.destroy_all
    pins = FactoryGirl.create_list(:pin, 3)
    presenter = PinPresenter.new
    expect(presenter.all_pins).to eq(pins.reverse)
  end
end