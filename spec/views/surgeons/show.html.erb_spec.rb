require "rails_helper"
require "cgi"

RSpec.describe "surgeons/show" do
  let(:surgeon) { create(:surgeon) }

  shared_examples "surgeon" do
    it "displays the surgeon" do
      assign(:surgeon, surgeon)
      assign(:pins_by_surgeon_procedure, {})
      assign(:procedures_by_id, {})
      assign(:satisfaction_by_procedure, {})
      assign(:procedure_count, 0)
      assign(:submission_count, 0)
      allow(view).to receive(:user_signed_in?).and_return(false)

      render

      expect(rendered).to include(CGI.escapeHTML(surgeon.to_s))
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
      assign(:pins_by_surgeon_procedure, { pin.procedure_id => 1 })
      assign(:procedures_by_id, { pin.procedure_id => pin.procedure })
      assign(:satisfaction_by_procedure, { pin.procedure_id => pin.satisfaction.to_f })
      assign(:procedure_count, 1)
      assign(:submission_count, 1)
      allow(view).to receive(:user_signed_in?).and_return(false)

      render

      expect(rendered).to match(Regexp.new(pin.procedure.name))
      expect(rendered).to match(Regexp.new(I18n.t('public.pin.average_satisfaction')))
    end

    it "shows the submission total only to signed-in users" do
      assign(:surgeon, surgeon)
      assign(:pins_by_surgeon_procedure, { pin.procedure_id => 1 })
      assign(:procedures_by_id, { pin.procedure_id => pin.procedure })
      assign(:satisfaction_by_procedure, { pin.procedure_id => pin.satisfaction.to_f })
      assign(:procedure_count, 1)
      assign(:submission_count, 1)
      allow(view).to receive(:user_signed_in?).and_return(true)

      render

      expect(rendered).to include("#{I18n.t('directory.submissions')}: 1")
    end
  end
end
