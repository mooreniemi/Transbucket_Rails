class RemoveSafeModeFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :safe_mode
  end

  def down
    add_column :users, :safe_mode, :boolean
  end
end
