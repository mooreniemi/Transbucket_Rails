class AddNotificationsToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :notification, :boolean
  end
end
