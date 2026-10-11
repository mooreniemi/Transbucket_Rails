class RemoveSensationAndSatisfactrionIndexesFromPins < ActiveRecord::Migration[4.2]
  def change
    remove_index :pins, :sensation
    remove_index :pins, :satisfaction
  end
end
