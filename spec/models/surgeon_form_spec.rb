require "rails_helper"

describe SurgeonForm do
  let(:surgeon) { build(:surgeon) }

  it "should have all the attributes of a surgeon" do
    form = SurgeonForm.new(surgeon)
    confirm_attributes(form, surgeon)
  end

  it "should normalize the surgeon's phone number" do
    form = SurgeonForm.new(Surgeon.new)

    form.validate(surgeon.attributes)
    form.save

    surgeon_result = Surgeon.where(url: surgeon.url)
    expect(surgeon_result).to exist
    expect(surgeon_result.first.phone).to eq(surgeon.phone.phony_normalized(default_country_code: 'US'))
  end
end
