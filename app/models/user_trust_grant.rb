class UserTrustGrant < ActiveRecord::Base
  # These are community roles. Admin remains a separate, explicit staff
  # permission on User rather than something inferred from a public badge.
  KINDS = %w(contributor vetted moderator).freeze
  SOURCES = %w(automatic moderator).freeze

  belongs_to :user
  belongs_to :granted_by, class_name: 'User', foreign_key: :granted_by_user_id

  validates :user, :kind, :source, :granted_at, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :source, inclusion: { in: SOURCES }

  scope :active, -> { where(revoked_at: nil) }

  def active?
    revoked_at.nil?
  end
end
