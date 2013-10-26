class AddSafeModeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :safe_mode, :boolean
  end
end
