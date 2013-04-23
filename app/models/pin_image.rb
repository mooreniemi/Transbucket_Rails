class PinImage < ActiveRecord::Base
  belongs_to :pin
  attr_accessible :photo, :caption, :pin_id

  has_attached_file :photo, styles: {medium: "320x240>"}
end
