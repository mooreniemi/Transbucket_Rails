require "rails_helper"

describe ProcedureForm do
  let(:procedure) { build(:procedure) }
  let(:form) { ProcedureForm.new(procedure) }

  it "should have all the attributes of a procedure" do
    confirm_attributes(form, procedure)
  end
end
