class AddSlugToProcedure < ActiveRecord::Migration[4.2]
  def change
    add_column :procedures, :slug, :string
    add_index :procedures, :slug, unique: true
  end
end
