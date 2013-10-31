require 'spec_helper'

describe SearchController do
  it "GET search_terms" do
    get 'search_terms'
    expect(JSON.parse(response.body)).to eq(expected_results)
  end

end

private

def expected_results
  Pin.uniq.pluck(:procedure) +  Pin.uniq.pluck(:surgeon)
end