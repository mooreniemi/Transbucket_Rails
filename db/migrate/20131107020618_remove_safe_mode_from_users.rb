class RemoveSafeModeFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :safe_mode
  end

  def down
    add_column :users, :safe_mode, :boolean
  end
end
