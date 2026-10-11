class AddIndexToPinImages < ActiveRecord::Migration[4.2]
  def change
    add_index(:pin_images, :pin_id)
  end
end
