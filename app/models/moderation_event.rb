class ModerationEvent < ActiveRecord::Base
  ACTIONS = %w[flag unflag].freeze
  CONTENT_TYPES = %w[Pin Comment].freeze

  belongs_to :user

  validates :action, inclusion: { in: ACTIONS }
  validates :content_type, inclusion: { in: CONTENT_TYPES }
  validates :content_id, presence: true
  validates :occurred_at, presence: true
end
