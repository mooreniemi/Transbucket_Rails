class AddLastNameToSurgeon < ActiveRecord::Migration
  def change
    add_column :surgeons, :last_name, :string
    rename_column :surgeons, :name, :first_name
  end
end
