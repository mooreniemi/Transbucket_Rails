require 'spec_helper'

describe PinFilterQuery, "#filtered" do
  it "handles nil just in case" do
    expect(PinFilterQuery.new({scope: nil}).filtered).to eq(Pin.none)
  end
  it "takes a filter options hash and returns an active record relation" do
    pin = create(:pin, procedure_id: 8)
    expect(PinFilterQuery.new({scope: ['top']}).filtered.first).to eq(Pin.first)
  end
end