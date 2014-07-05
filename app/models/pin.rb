class Pin < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  include Constants

  has_many :pin_images, :dependent => :destroy
  has_many :comments, :foreign_key => 'commentable_id', :class_name => "ActsAsVotable::Vote"

  belongs_to :user
  belongs_to :surgeon
  belongs_to :procedure

  # attr_accessible :surgeon_attributes, :procedure_attributes, :pin_images_attributes
  # attr_accessible :description, :pin_images, :surgeon_id, :cost, :revision, :details, :procedure_id, :username, :user_id, :id, :created_at, :sensation, :satisfaction

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| !attributes.keys.include?(:photo) }
  accepts_nested_attributes_for :surgeon, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }
  accepts_nested_attributes_for :procedure, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  validates :surgeon_id, presence: true
  validates :procedure_id, presence: true
  validates :user_id, presence: true
  validates :pin_images, presence: true

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :tags

  scope :published, includes(:pin_images, :user, :surgeon, :procedure).where(state: 'published')
  scope :pending, includes(:pin_images, :user, :surgeon, :procedure).where(state: 'pending')

  scope :mtf, where(["procedure_id in (?)", Constants::MTF_IDS.map(&:to_s)])
  scope :ftm, where(["procedure_id in (?)", Constants::FTM_IDS.map(&:to_s)])
  scope :top, where(["procedure_id in (?)", Constants::TOP_IDS.map(&:to_s)])
  scope :bottom, where(["procedure_id in (?)", Constants::BOTTOM_IDS.map(&:to_s)])

  scope :need_category, where(procedure_id: 911)
  scope :recent, lambda { published.order("created_at desc") }

  scope :by_user, lambda {|user| includes(:pin_images, :user, :surgeon, :procedure).where(user_id: user)}
  scope :by_procedure, lambda {|procedure| where(procedure_id: procedure)}
  scope :by_surgeon, lambda {|surgeon| where(surgeon_id: surgeon)}

  # TODO yank this out
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
