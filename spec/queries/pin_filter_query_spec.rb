require 'rails_helper'

describe PinFilterQuery, "#filtered" do
  let(:procedure) { create(:procedure, id: Constants::TOP_IDS[0]) }
  let!(:pin) { create(:pin, procedure: procedure) }

  it "handles nil just in case" do
    expect(PinFilterQuery.new({scope: nil}).filtered).to eq(Pin.none)
  end
  it "takes a filter options hash and returns an active record relation" do
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
  end
  it 'caches filters' do
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
    expect(Pin).to_not receive(:top)
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
  end
end
