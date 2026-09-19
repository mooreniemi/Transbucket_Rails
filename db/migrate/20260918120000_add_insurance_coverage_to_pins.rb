class AddInsuranceCoverageToPins < ActiveRecord::Migration
  def change
    add_column :pins, :covered_by_insurance, :boolean
  end
end
