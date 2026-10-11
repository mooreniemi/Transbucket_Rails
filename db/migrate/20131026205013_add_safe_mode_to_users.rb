class AddSafeModeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :safe_mode, :boolean
  end
end
