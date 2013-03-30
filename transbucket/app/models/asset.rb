class Asset < ActiveRecord::Base
  attr_accessible :image, :pin_id
  belongs_to :pin
  validates_associated :pin

  has_attached_file :image, :styles => {:large =>"640x480", :medium => "300x300>"}

  validates_attachment :image, presence: true,
  			content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']},
 			 size: {less_than: 6.megabytes }
  
end
