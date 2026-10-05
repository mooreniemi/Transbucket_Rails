class Discussion < ActiveRecord::Base
  VISIBILITIES = %w[everyone contributors].freeze
  CATEGORIES = %w[discussion question experience recovery planning resources community].freeze

  belongs_to :user
  acts_as_commentable

  include AASM
  include CommentsHelper

  validates :user, :title, :body, :category, presence: true
  validates :title, length: { in: 3..160 }
  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :category, inclusion: { in: CATEGORIES }

  aasm column: :state do
    state :pending, value: 'pending'
    state :published, value: 'published', initial: :published

    event :publish do
      transitions from: :pending, to: :published
    end
  end

  scope :published, -> { where("discussions.state IS NULL OR discussions.state IN ('', 'published')") }

  def self.visible_to(user)
    return where(visibility: 'everyone') if user.blank?
    return all if user.respond_to?(:moderator?) && user.moderator?

    contributor = sanitize_sql_array([
      "EXISTS (SELECT 1 FROM user_trust_grants grants WHERE grants.user_id = ? AND grants.revoked_at IS NULL AND grants.kind IN (?, ?, ?))",
      user.id, 'contributor', 'vetted', 'moderator'
    ])
    where("discussions.visibility = 'everyone' OR discussions.user_id = ? OR (discussions.visibility = 'contributors' AND (#{contributor}))", user.id).
      distinct
  end

  def contextual?
    false
  end
end
