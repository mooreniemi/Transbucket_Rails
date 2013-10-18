class AddStateToPins < ActiveRecord::Migration
  def change
    add_column :pins, :state, :string
  end
end
