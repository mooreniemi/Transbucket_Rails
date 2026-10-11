class AddNotificationsToPreferences < ActiveRecord::Migration[4.2]
  def change
    add_column :preferences, :notification, :boolean
  end
end
