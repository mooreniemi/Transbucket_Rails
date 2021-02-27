# "Pin" as a name is baggage from the original app,
# generic "pinning" of content.
# Now it is the primary submission model.
class Pin < ActiveRecord::Base
  include AASM
  include Searchable
  include Constants
  include PinsHelper
  include CommentsHelper
  include NotificationsHelper

  belongs_to :user
  belongs_to :surgeon
  belongs_to :procedure

  has_many :pin_images, dependent: :destroy

  attr_accessor :pin_image_ids

  acts_as_commentable
  acts_as_votable
  acts_as_taggable_on :complications

  # we have so few records we don't really need multiple shards
  settings index: { number_of_shards: 1 } do
    mapping do
      # no need to do full text search on this
      indexes :state, type: 'keyword'
      # keyword (exact term) doesn't make sense for these
      indexes :description, type: 'text', analyzer: 'english'
      indexes :details, type: 'text', analyzer: 'english'

      # we use the english analyzer, and do keywords as well as text
      # because then we can do significant terms aggregations
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html#english-analyzer
      indexes :complications do
        indexes :name, type: 'text', analyzer: 'english' do
          indexes :keyword, type: 'keyword'
        end
      end
      indexes :surgeon do
        indexes :pretty_name, type: 'text', analyzer: 'english' do
          indexes :keyword, type: 'keyword'
        end
      end
      indexes :procedure do
        indexes :name, type: 'text', analyzer: 'english' do
          indexes :keyword, type: 'keyword'
        end
        indexes :description, type: 'text', analyzer: 'english'
      end
      indexes :pin_images do
        indexes :caption, type: 'text', analyzer: 'english'
      end
    end
  end

  def as_indexed_json(options={})
    hash = self.as_json(
      only: [
        :id, :user_id, :procedure_id, :surgeon_id, :state, :username,
        :updated_at, :created_at, :description, :details,
        :satisfaction, :sensation, :revision, :cost
      ],
      include: {
        surgeon: { methods: [:pretty_name], only: [:pretty_name] },
        procedure: { only: [:name, :description] },
        pin_images: { only: [:caption] },
        complications: { only: [:name] }
      }
    )
    hash
  end

  validates :surgeon, presence: true
  validates :procedure, presence: true
  validates :user_id, presence: true
  validates :pin_images, presence: true

  aasm column: :state do
    state :pending, value: 'pending'
    state :published, value: 'published', initial: :published

    event :publish do
      transitions from: :pending, to: :published
    end

    event :review, :after => :admin_review do
      transitions from: :published, to: :pending
    end
  end

  def self.mtf
    where(['procedure_id in (?)', Constants::MTF_IDS])
  end

  def self.ftm
    where(['procedure_id in (?)', Constants::FTM_IDS])
  end

  def self.top
    where(['procedure_id in (?)', Constants::TOP_IDS])
  end

  def self.bottom
    where(['procedure_id in (?)', Constants::BOTTOM_IDS])
  end

  def self.need_category
    where(procedure_id: 911)
  end

  def self.recent
    published.order('updated_at desc')
  end

  def self.by_gender(gender_name)
    unless Gender.pluck(:name).include?(gender_name)
      raise Exception.new "Invalid Gender name"
    end
    joins('LEFT JOIN procedures on pins.procedure_id = procedures.id').where(procedures: { gender: gender_name })
  end

  def self.by_user_gender(user)
    by_gender(user.gender.name)
  end

  def self.by_user(user)
    includes(:pin_images, :user, :surgeon, :procedure).where(user_id: user)
  end

  def self.by_procedure(procedure)
    if procedure == [nil]
      where.not(procedure_id: procedure)
    else
      where(procedure_id: procedure)
    end
  end

  def self.by_surgeon(surgeon)
    if surgeon == [nil]
      where.not(surgeon_id: surgeon)
    else
      where(surgeon_id: surgeon)
    end
  end
end
