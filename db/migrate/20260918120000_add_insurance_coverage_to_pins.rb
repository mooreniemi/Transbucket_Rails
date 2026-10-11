class AddInsuranceCoverageToPins < ActiveRecord::Migration[4.2]
  def change
    add_column :pins, :covered_by_insurance, :boolean
  end
end
