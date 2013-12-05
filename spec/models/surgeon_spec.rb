require 'spec_helper'

describe Surgeon do
  it 'has last name' do
    surgeon = create(:surgeon)
    expect(surgeon.last_name).to_not be_nil
  end
end
