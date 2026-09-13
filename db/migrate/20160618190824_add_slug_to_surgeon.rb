class AddSlugToSurgeon < ActiveRecord::Migration[4.2]
  def change
    add_column :surgeons, :slug, :string
    add_index :surgeons, :slug, unique: true
  end
end
