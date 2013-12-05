require 'spec_helper'

describe Procedure do
  it 'has gender' do
    procedure = create(:procedure)
    expect(procedure.gender).to_not be_nil
  end
end
