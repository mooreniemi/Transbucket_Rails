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

  FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
  MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery"]
  TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
  BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty"]
  PROCEDURES = Pin.uniq.pluck(:procedure)

  SCOPES = ["ftm", "mtf", "bottom", "top", "need_category"]

  scope :published, where(state: 'published')
  scope :pending, where(state: 'pending')
  scope :mtf, where(["procedure in (?)", MTF])
  scope :ftm, where(["procedure in (?)", FTM])
  scope :top, where(["procedure in (?)", TOP])
  scope :bottom, where(["procedure in (?)", BOTTOM])
  scope :need_category, where(procedure: "other")


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
