class AddDescriptionToProcedure < ActiveRecord::Migration
  def change
    add_column :procedures, :description, :string
  end
end
