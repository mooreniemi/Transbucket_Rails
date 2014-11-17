class Pin < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  include Constants

  belongs_to :user
  belongs_to :surgeon
  belongs_to :procedure

  has_many :pin_images, :dependent => :destroy
  has_many :comments, :foreign_key => 'commentable_id'

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| !attributes.keys.include?(:photo) }

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :tags

  validates :surgeon_id, presence: true
  validates :procedure_id, presence: true
  validates :user_id, presence: true
  validates :pin_images, presence: true

  scope :mtf, -> {where(["procedure_id in (?)", Constants::MTF_IDS.map(&:to_s)])}
  scope :ftm, -> {where(["procedure_id in (?)", Constants::FTM_IDS.map(&:to_s)])}
  scope :top, -> {where(["procedure_id in (?)", Constants::TOP_IDS.map(&:to_s)])}
  scope :bottom, -> {where(["procedure_id in (?)", Constants::BOTTOM_IDS.map(&:to_s)])}

  scope :published, -> { includes(:pin_images, :user, :surgeon, :procedure).where(state: 'published') }
  scope :pending, -> { includes(:pin_images, :user, :surgeon, :procedure).where(state: 'pending') }

  scope :need_category, -> { where(procedure_id: 911) }
  scope :recent, -> { published.order("created_at desc") }

  scope :by_user, ->(user) { includes(:pin_images, :user, :surgeon, :procedure).where(user_id: user) }
  scope :by_procedure, ->(procedure) { where(procedure_id: procedure) }
  scope :by_surgeon, ->(surgeon) { where(surgeon_id: surgeon) }

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

  # TODO yank this out
  def cover_image(safe_mode=false)
    image = safe_mode == true ? 'http://placekitten.com/200/300' : images.try(:last).try(:photo, :medium)
    image
  end

  def images
    self.pin_images.collect {|p| p if p.photo(:medium).present? }
  end

  def unknown_surgeon?
    surgeon.id == 911
  end

  def latest_comment_snippet
    try(:comment_threads).try(:snippet)
  end
end
