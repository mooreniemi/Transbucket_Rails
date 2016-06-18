class RemoveSensationAndSatisfactrionIndexesFromPins < ActiveRecord::Migration
  def change
    remove_index :pins, :sensation
    remove_index :pins, :satisfaction
  end
end
