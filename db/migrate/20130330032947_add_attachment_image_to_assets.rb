class AddAttachmentImageToAssets < ActiveRecord::Migration
  def self.up
    change_table :assets do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :assets, :image
  end
end
