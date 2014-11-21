require 'spec_helper'

describe SearchController, :type => :controller do
  it "GET search_terms" do
    expect(Procedure).to receive(:names).and_return(["foo"])
    expect(Surgeon).to receive(:names).and_return(["Dippity"])

    get 'search_terms', term: "foo"
    expect(JSON.parse(response.body)["match"]).to include("foo")
  end
end
