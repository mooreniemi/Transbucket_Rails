require 'rails_helper'

describe Procedure do
  describe "is properly normalized" do
    it 'is saved lowercase' do
      procedure = Procedure.new(name: "Something Uppercase")
      procedure.save!
      expect(procedure.name).to eq("something uppercase")
    end
    it 'thus considers different cased attempts duplicates' do
      procedure = Procedure.new(name: "Something Uppercase")
      procedure.save!
      procedure_dup = Procedure.new(name: "something uppercase")
      expect(procedure_dup.valid?).to eq(false)
      expect(procedure_dup.errors.messages).to eq({"name": ["has already been taken"] })
      expect(procedure_dup.save).to eq(false)
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
