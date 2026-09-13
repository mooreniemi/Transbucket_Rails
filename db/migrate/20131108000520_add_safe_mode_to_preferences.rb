class AddSafeModeToPreferences < ActiveRecord::Migration[4.2]
  def change
    add_column :preferences, :safe_mode, :boolean
  end
end
