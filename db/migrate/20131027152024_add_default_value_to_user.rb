class AddDefaultValueToUser < ActiveRecord::Migration
  def self.up
    change_column :users, :safe_mode, :boolean, :default => false
    User.update_all(:safe_mode => false)
  end
end
