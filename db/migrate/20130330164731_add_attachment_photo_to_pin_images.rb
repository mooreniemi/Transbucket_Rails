class AddAttachmentPhotoToPinImages < ActiveRecord::Migration
  def self.up
    change_table :pin_images do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :pin_images, :photo
  end
end
