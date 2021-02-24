require "rails_helper"

RSpec.describe "surgeons/show" do
  let(:surgeon) { create(:surgeon) }

  shared_examples "surgeon" do
    it "displays the surgeon" do
      assign(:surgeon, surgeon)
      assign(:pins_by_surgeon_procedure, {})

      render

      expect(rendered).to match Regexp.new(surgeon.to_s)
    end
  end

  context "with no pins" do
    include_examples "surgeon"
  end

  context "with one pin" do
    let!(:pin) { create(:pin, surgeon: surgeon, satisfaction: 1) }

    include_examples "surgeon"

    it "shows the relevant procedures" do
      assign(:surgeon, surgeon)
      assign(:pins_by_surgeon_procedure, { [surgeon.id, pin.procedure_id] => 1})

      render

      expect(rendered).to match(Regexp.new(pin.procedure.name))
      expect(rendered).to match(Regexp.new("Average patient satisfaction"))
    end
  end
end
