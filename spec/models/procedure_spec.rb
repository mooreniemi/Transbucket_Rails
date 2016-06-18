require 'rails_helper'

describe Procedure do
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
end
