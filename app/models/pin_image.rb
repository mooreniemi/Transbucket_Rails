# PinImages is probably somewhat confusing.
# Probably should've just stuck paperclip on pin.
class PinImage < ActiveRecord::Base
  include Searchable
  belongs_to :pin

  settings index: { number_of_shards: 3, number_of_replicas: 0 } do
  end

  has_attached_file :photo,
    styles: { medium: '320x240>', thumb: '100x100#' },
    default_url: 'http://placekitten.com/200/300'
  validates_attachment_content_type :photo,
    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
