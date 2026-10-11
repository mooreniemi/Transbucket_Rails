class AddDescriptionToProcedure < ActiveRecord::Migration[4.2]
  def change
    add_column :procedures, :description, :string
  end
end
