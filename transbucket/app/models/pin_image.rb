class PinImage < ActiveRecord::Base
  belongs_to :pin
  attr_accessible :photo, :caption, :pin_id

  validates_attachment :photo, presence: true,
  			content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']},
 			 size: {less_than: 6.megabytes }
  

  has_attached_file :photo, styles: {medium: "320x240>"}
end
