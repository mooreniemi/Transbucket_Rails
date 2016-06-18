class AddSlugToSurgeon < ActiveRecord::Migration
  def change
    add_column :surgeons, :slug, :string
    add_index :surgeons, :slug, unique: true
  end
end
