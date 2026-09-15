require 'rails_helper'

describe ComparisonStatistics do
  def data(distribution)
    { distributions: { sensation: distribution, satisfaction: distribution } }
  end

  it 'warns when either rating sample is small' do
    result = described_class.for(data(5 => 2), data(1 => 2))[:sensation]

    expect(result[:first_rated]).to eq(2)
    expect(result[:second_rated]).to eq(2)
    expect(result[:insufficient_data]).to eq(true)
  end

  it 'calculates an exact probability for a 2x2 rating comparison' do
    expect(described_class.fisher_exact_p_value(8, 2, 2, 8)).to be_within(0.000001).of(0.023014)
  end
end
