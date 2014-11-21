require 'spec_helper'

describe Procedure do
  it 'has gender' do
    procedure = create(:procedure)
    expect(procedure.gender).to_not be_nil
  end

  it 'has #names' do
    create_list(:procedure, 3)
    names = Procedure.where("name IS NOT NULL")
    .pluck(:name)
    .sort
    expect(Procedure.names).to eq(names)
  end
end
