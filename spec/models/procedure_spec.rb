require 'rails_helper'

describe Procedure do
  describe "normalization" do
    it 'is stored lowercase' do
      procedure = build(:procedure)
      procedure.name = "Something We Know Is Capitalized"
      procedure.save!
      expect(procedure.name).to eq("something we know is capitalized")
    end
    it 'is unique irrespective of case' do
      procedure = build(:procedure)
      procedure.name = "Something We Know Is Capitalized"
      procedure.save!
      procedure2 = build(:procedure)
      procedure2.name = "something we know is capitalized"
      expect {
        procedure2.save!
      }.to raise_error(
        ActiveRecord::RecordInvalid,
        "Validation failed: Name has already been taken"
      )
    end
  end
  describe "#recalculate_avgs" do
    it 'calculates avg sensation' do
      procedure = create(:procedure, :uncomputed)
      create(:pin, sensation: 3, procedure_id: procedure.id)

      procedure.recalculate_avgs
      expect(procedure.reload.avg_sensation).to eq(3)

      create(:pin, procedure_id: procedure.id, sensation: 5)
      procedure.recalculate_avgs
      expect(procedure.reload.avg_sensation).to eq(4)
    end
  end
  it 'has #names' do
    create_list(:procedure, 3)
    names = Procedure.pluck(:name).sort
    expect(Procedure.names).to eq(names)
  end
  it 'can be commented on' do
    user = create(:user)
    procedure = create(:procedure)
    CommentService.new(procedure, user, "good procedure").create
    expect(procedure.root_comments.first.body).to eq("good procedure")
  end
end
