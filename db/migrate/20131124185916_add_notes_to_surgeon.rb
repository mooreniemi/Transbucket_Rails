class AddNotesToSurgeon < ActiveRecord::Migration
  def change
    add_column :surgeons, :notes, :string
  end
end
