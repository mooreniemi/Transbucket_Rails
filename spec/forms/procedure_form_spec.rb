require 'rails_helper'
require 'faker'

describe "ProcedureForm" do
  let(:procedure) { create(:procedure) }

  context "validation" do
    it "rejects when not unique name" do
      procedure_form = ProcedureForm.new(Procedure.new)
      expect(procedure_form.validate(procedure.attributes)).to be false
    end
    it "accepts when unique name" do
      procedure_form = ProcedureForm.new(Procedure.new)
      existing_procedure_attrs = procedure.attributes
      existing_procedure_attrs[:name] = "Very Unique Name"
      expect(procedure_form.validate(existing_procedure_attrs)).to be true
    end
  end
end
