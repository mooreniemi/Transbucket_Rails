require "rails_helper"

describe SurgeonForm do
  let(:surgeon) { build(:surgeon) }
  let(:form) { SurgeonForm.new(surgeon) }

  it "should have all the attributes of a surgeon" do
    confirm_attributes(form, surgeon)
  end
end
