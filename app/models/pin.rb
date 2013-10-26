class Pin < ActiveRecord::Base
  has_many :pin_images, :dependent => :destroy
  has_many :comments

  attr_accessible :description, :pin_images, :pin_images_attributes, :surgeon, :cost, :revision, :details, :procedure, :username, :id, :created_at

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  validates :surgeon, presence: true
  validates :procedure, presence: true
  #validates :pin_images, presence: true
  validates :user_id, presence: true

  belongs_to :user

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :tags

  def cover_image(safe_mode=false)
    images = self.pin_images.collect {|p| p if p.photo(:medium).present? }
    image = safe_mode == true ? 'http://placekitten.com/200/300' : images.last.photo(:medium)
    return image
  end

  state_machine initial: :published do
    state :pending, value: "pending"
    state :published, value: "published"

    event :publish do
      transition nil => :published
      transition :pending => :published
    end

    event :review do
      transition :published => :pending
    end
  end

end
