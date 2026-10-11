class AddNotesToSurgeon < ActiveRecord::Migration[4.2]
  def change
    add_column :surgeons, :notes, :string
  end
end
