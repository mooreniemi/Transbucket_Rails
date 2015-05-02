# "Pin" as a name is baggage from the original app,
# generic "pinning" of content.
# Now it is the primary submission model.
class Pin < ActiveRecord::Base
  include AASM
  include ThinkingSphinx::Scopes
  include Constants

  belongs_to :user
  belongs_to :surgeon
  belongs_to :procedure

  has_many :pin_images, dependent: :destroy
  has_many :comments, foreign_key: 'commentable_id'

  attr_accessor :pin_image_ids

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :tags

  validates :surgeon_id, presence: true
  validates :procedure_id, presence: true
  validates :user_id, presence: true
  validates :pin_images, presence: true

  def self.mtf
    where(['procedure_id in (?)', Constants::MTF_IDS.map(&:to_s)])
  end

  def self.ftm
    where(['procedure_id in (?)', Constants::FTM_IDS.map(&:to_s)])
  end

  def self.top
    where(['procedure_id in (?)', Constants::TOP_IDS.map(&:to_s)])
  end

  def self.bottom
    where(['procedure_id in (?)', Constants::BOTTOM_IDS.map(&:to_s)])
  end

  def self.need_category
    where(procedure_id: 911)
  end

  def self.recent
    published.order('created_at desc')
  end

  def self.by_user(user)
    includes(:pin_images, :user, :surgeon, :procedure).where(user_id: user)
  end

  def self.by_procedure(procedure)
    where(procedure_id: procedure)
  end

  def self.by_surgeon(surgeon)
    where(surgeon_id: surgeon)
  end

  aasm column: :state do
    state :pending, value: 'pending'
    state :published, value: 'published', initial: :published

    event :publish do
      transitions from: :pending, to: :published
    end

    event :review do
      transitions from: :published, to: :pending
    end
  end

  # TODO: many of the below methods belong elsewhere
  def cover_image(safe_mode = false)
    kitty_url = 'http://placekitten.com/200/300'
    image = safe_mode == true ? kitty_url : images.try(:last)
    image
  end

  def images
    pin_images.all_mediums
  end

  def unknown_surgeon?
    if surgeon.present?
      surgeon.id == 911
    else
      update_attributes(surgeon_id: 911)
    end
  end

  def latest_comment_snippet
    try(:comment_threads).try(:snippet)
  end
end
