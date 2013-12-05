require 'spec_helper'

describe SearchController do
  it "GET search_terms" do
    get 'search_terms'
    expect(JSON.parse(response.body).sort).to eq(expected_results.sort)
  end

end

private

def expected_results
  (Procedure.uniq.pluck(:name) + Surgeon.names)
end