class AddSensationAndSatisfactionIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :pins, :sensation
    add_index :pins, :satisfaction
  end
end
