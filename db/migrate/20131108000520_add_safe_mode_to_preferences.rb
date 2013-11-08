class AddSafeModeToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :safe_mode, :boolean
  end
end
