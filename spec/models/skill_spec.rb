require 'rails_helper'

describe Skill do
  let!(:surgeon) {create(:surgeon)}
  let!(:procedure) {create(:procedure)}
  let!(:skill) {create(:skill, surgeon_id: surgeon.id, procedure_id: procedure.id)}

  it "associates a surgeon to a procedure" do
    expect(surgeon.procedures.first.id).to eq(skill.procedure_id)
  end
end
