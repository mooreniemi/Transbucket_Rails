class AddSensationAndSatisfactionIndexes < ActiveRecord::Migration
  def change
    add_index :pins, :sensation
    add_index :pins, :satisfaction
  end
end
