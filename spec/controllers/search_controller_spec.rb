require 'spec_helper'

describe SearchController do
  it "GET search_terms" do
    get 'search_terms'
    expect(JSON.parse(response.body).sort).to eq(expected_results.sort)
  end

end

private

def expected_results
  (Pin.uniq.pluck(:procedure) + Pin.uniq.pluck(:surgeon)).compact.reject(&:blank?).uniq.each{ |e| e.gsub!(/[\W]/, ' ') }
end