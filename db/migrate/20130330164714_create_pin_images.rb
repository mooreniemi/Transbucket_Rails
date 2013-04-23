class CreatePinImages < ActiveRecord::Migration
  def change
    create_table :pin_images do |t|
      t.string :caption
      t.integer :pin_id

      t.timestamps
    end
  end
end
