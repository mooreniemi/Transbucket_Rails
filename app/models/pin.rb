class Pin < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  has_many :pin_images, :dependent => :destroy
  has_many :comments

  belongs_to :surgeon
  belongs_to :procedure

  attr_accessible :surgeon_attributes, :procedure_attributes, :pin_images_attributes
  attr_accessible :description, :pin_images, :surgeon_id, :cost, :revision, :details, :procedure_id, :username, :id, :created_at, :sensation, :satisfaction

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }
  accepts_nested_attributes_for :surgeon, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }
  accepts_nested_attributes_for :procedure, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  validates :surgeon_id, presence: true
  validates :procedure_id, presence: true
  validates :user_id, presence: true

  belongs_to :user

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :tags

  FTM = ["phalloplasty", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision"]
  MTF = ["vaginoplasty", "breast augmentation", "facial feminization surgery"]
  TOP = ["breast augmentation", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "t anchor double incision"]
  BOTTOM = ["vaginoplasty", "phalloplasty", "metoidioplasty"]
  PROCEDURES = Pin.uniq.pluck(:procedure_id)
  SURGEONS = Pin.uniq.pluck(:surgeon_id)

  SCOPES = ["ftm", "mtf", "bottom", "top", "need_category"]

  scope :published, includes(:pin_images, :user).where(state: 'published')
  scope :pending, includes(:pin_images, :user).where(state: 'pending')
  scope :mtf, where(["procedure in (?)", MTF])
  scope :ftm, where(["procedure in (?)", FTM])
  scope :top, where(["procedure in (?)", TOP])
  scope :bottom, where(["procedure in (?)", BOTTOM])
  scope :need_category, where(procedure: "other")
  scope :recent, lambda { published.order("created_at desc") }
  scope :by_user, lambda {|user| where(user_id: user.id)}
  scope :by_procedure, lambda {|procedure| where(procedure_id: Procedure.find_by_name(procedure).id)}
  scope :by_surgeon, lambda {|surgeon| where(surgeon_id: Surgeon.find_by_last_name(surgeon.split(',').first).id)}

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
