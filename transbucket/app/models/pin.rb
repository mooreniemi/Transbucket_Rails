class Pin < ActiveRecord::Base
  has_many :pin_images, :dependent => :destroy
  attr_accessible :description, :pin_images, :pin_images_attributes

  accepts_nested_attributes_for :pin_images #, :reject_if => lambda { |t| t['pin_image'].nil? }

  validates :description, presence: true
  #validates :pin_images_attributes, presence: true
  validates :user_id, presence: true

  belongs_to :user
end
