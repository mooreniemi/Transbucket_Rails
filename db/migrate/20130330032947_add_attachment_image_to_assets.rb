class AddAttachmentImageToAssets < ActiveRecord::Migration[4.2]
  def self.up
    change_table :assets do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :assets, :image
  end
end
