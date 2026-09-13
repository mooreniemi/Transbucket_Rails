class AddRatingsToPin < ActiveRecord::Migration[4.2]
  def change
    add_column :pins, :sensation, :integer
    add_column :pins, :satisfaction, :integer
  end
end
