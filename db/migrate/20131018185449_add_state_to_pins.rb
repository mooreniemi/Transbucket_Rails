class AddStateToPins < ActiveRecord::Migration[4.2]
  def change
    add_column :pins, :state, :string
  end
end
