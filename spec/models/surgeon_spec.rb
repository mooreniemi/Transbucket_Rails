require 'rails_helper'

describe Surgeon do
  it 'requires a last_name' do
    expect{ Surgeon.create!(first_name: "Larry") }.
      to raise_error("Validation failed: Last name can't be blank")
  end

  it 'first and last name must be unique' do
    first_surgeon = create(:surgeon)
    dupe_surgeon_attrs = first_surgeon.attributes.except("id")
    expect { Surgeon.create!(dupe_surgeon_attrs) }.
      to raise_error("Validation failed: Last name has already been taken")
  end

  it 'last names can be dupe if first distinct' do
    first_surgeon = create(:surgeon)
    new_surgeon = create(:surgeon, last_name: first_surgeon.last_name, first_name: "cthulu")
    expect(new_surgeon.first_name).to_not eq(first_surgeon.first_name)
    expect(new_surgeon.last_name).to eq(first_surgeon.last_name)
  end

  describe "#satisfaction_by_procedure" do
    it 'gives procedure id and average satisfaction' do
      pin = create(:pin, :with_surgeon_and_procedure, satisfaction: rand(5) + 1)
      expect(pin.surgeon.satisfaction_by_procedure).
        to eq({ pin.procedure.id => pin.satisfaction})
    end
  end

  describe "#to_s" do
    it 'displays the surgeon name like Last, First' do
      surgeon = build(:surgeon, first_name: "larry", last_name: "schmoe")
      expect(surgeon.to_s).to eq("Schmoe, Larry")
    end
  end

  describe ".names" do
    it 'provides a list of names formatted for SearchController' do
      surgeons = create_list(:surgeon, 2)
      name_string = "#{surgeons[0].last_name}, #{surgeons[0].first_name}"
      expect(Surgeon.names).to include(name_string)
    end
  end
end
