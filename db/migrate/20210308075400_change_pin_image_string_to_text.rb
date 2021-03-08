class ChangePinImageStringToText < ActiveRecord::Migration
  def change
    change_column :pin_images, :caption, :text
  end
end
