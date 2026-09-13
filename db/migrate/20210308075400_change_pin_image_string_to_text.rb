class ChangePinImageStringToText < ActiveRecord::Migration[4.2]
  def change
    change_column :pin_images, :caption, :text
  end
end
