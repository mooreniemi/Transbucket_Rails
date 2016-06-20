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

  it 'handles different combinations of query' do
    all_filters = {scope: 'top', surgeon: pin.surgeon.id.to_s, procedure: pin.procedure.id.to_s}
    (1..all_filters.size).each do |size|
      all_filters.keys.combination(size).each do |keys|
        filter = {}
        keys.each { |k| filter[k] = [all_filters[k]] }
        expect(PinFilterQuery.new(filter).filtered.first).to eq(pin)
      end
    end
  end
end
