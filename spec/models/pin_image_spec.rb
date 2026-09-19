require 'rails_helper'

RSpec.describe PinImage, type: :model do
  describe 'photo upload size' do
    it 'rejects photos larger than one megabyte' do
      oversized_photo = Tempfile.new(['large-photo', '.jpg'])
      oversized_photo.binmode
      oversized_photo.write(File.binread(Rails.root.join('spec/fixtures/cat.jpg')))
      oversized_photo.truncate(PinImage::UPLOAD_SIZE_LIMIT + 1)
      oversized_photo.rewind

      pin_image = build(:pin_image, photo: oversized_photo)

      expect(pin_image).not_to be_valid
      expect(pin_image.errors[:photo_file_size]).to be_present
    ensure
      oversized_photo.close!
    end

    it 'allows edits to a legacy oversized photo without replacing it' do
      pin_image = build(:pin_image, photo_file_size: PinImage::UPLOAD_SIZE_LIMIT + 1)
      pin_image.save!(validate: false)
      pin_image.caption = 'Updated caption'

      expect(pin_image).to be_valid
    end
  end
end
