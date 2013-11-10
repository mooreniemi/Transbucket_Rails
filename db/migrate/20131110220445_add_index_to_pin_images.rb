class AddIndexToPinImages < ActiveRecord::Migration
  def change
    add_index(:pin_images, :pin_id)
  end
end
