# PinImages is probably somewhat confusing.
# Probably should've just stuck paperclip on pin.
class PinImage < ActiveRecord::Base
  UPLOAD_SIZE_LIMIT = 1.megabyte

  belongs_to :pin

  has_attached_file :photo,
    styles: { medium: '320x240>', thumb: '100x100#' },
    default_url: 'http://placekitten.com/200/300'

  validates_attachment_content_type :photo,
    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  # Do not lock people out of editing pins that contain legacy oversized
  # images. The limit applies whenever a photo is newly attached or replaced.
  validates_attachment_size :photo,
    less_than_or_equal_to: UPLOAD_SIZE_LIMIT,
    if: :photo_file_size_changed?
end
