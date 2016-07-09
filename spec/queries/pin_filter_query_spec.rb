require 'rails_helper'

describe PinFilterQuery, "#filtered" do
  before(:each) do
    Rails.cache.clear
  end

  let(:procedure) { create(:procedure, id: Constants::TOP_IDS[0]) }
  let!(:pin) do
    pin = create(:pin, procedure: procedure)
    pin.complication_list = "hematoma"
    pin.save
    pin.reload
  end

  it 'takes a filter options hash and returns an active record relation' do
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
  end
  it 'caches filters' do
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
    expect(Pin).to_not receive(:top)
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(pin)
  end

  it 'handles different combinations of query' do
    all_filters = {
      scope: 'top',
      surgeon: pin.surgeon.id.to_s,
      procedure: pin.procedure.id.to_s,
      complication: 'hematoma'
    }
    (1..all_filters.size).each do |size|
      all_filters.keys.combination(size).each do |keys|
        filter = {}
        keys.each { |k| filter[k] = [all_filters[k]] }
        expect(PinFilterQuery.new(filter).filtered.first).to eq(pin)
      end
    end
  end
end
