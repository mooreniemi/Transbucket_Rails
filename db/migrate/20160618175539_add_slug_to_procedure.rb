class AddSlugToProcedure < ActiveRecord::Migration
  def change
    add_column :procedures, :slug, :string
    add_index :procedures, :slug, unique: true
  end
end
