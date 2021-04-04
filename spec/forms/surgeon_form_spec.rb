require 'rails_helper'
require 'faker'

describe "SurgeonForm" do
  let(:surgeon) { create(:surgeon) }

  context "validation" do
    it "rejects when not unique first and last name" do
      surgeon_form = SurgeonForm.new(Surgeon.new)
      expect(surgeon_form.validate(surgeon.attributes)).to be false
    end
    it "accepts when same last name but different first name" do
      surgeon_form = SurgeonForm.new(Surgeon.new)
      unique_first_name_attrs = surgeon.attributes
      unique_first_name_attrs[:first_name] = "Felix the Cat"
      expect(surgeon_form.validate(unique_first_name_attrs)).to be true
    end
  end
end
