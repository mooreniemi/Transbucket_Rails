class SetDefaultsOnPreferences < ActiveRecord::Migration[4.2]
  def up
    change_column :preferences, :safe_mode, :boolean, :default => false
    change_column :preferences, :notification, :boolean, :default => true
  end

  def down
  end
end
