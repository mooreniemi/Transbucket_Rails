class AddRatingsToPin < ActiveRecord::Migration
  def change
    add_column :pins, :sensation, :integer
    add_column :pins, :satisfaction, :integer
  end
end
