class Pin < ActiveRecord::Base
  has_many :pin_images, :dependent => :destroy
  has_many :comments
  
  attr_accessible :description, :pin_images, :pin_images_attributes, :surgeon, :cost, :revision, :details, :procedure

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  validates :surgeon, presence: true
  validates :procedure, presence: true
  #validates :pin_images, presence: true
  validates :user_id, presence: true

  belongs_to :user

  acts_as_commentable
end
