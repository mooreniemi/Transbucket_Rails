class ContentEvent < ActiveRecord::Base
  CONTENT_TYPES = %w[Pin Procedure Surgeon].freeze
  EVENT_TYPES = %w[impression open view submission_created submission_updated].freeze
  SOURCES = %w[server client].freeze

  belongs_to :user

  validates :content_type, inclusion: { in: CONTENT_TYPES }
  validates :content_id, presence: true
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :source, inclusion: { in: SOURCES }
  validates :occurred_at, presence: true
  validate :has_an_actor
  validate :has_supported_client_context
  validate :has_supported_event_context

  private

  def has_an_actor
    return if user_id.present? || visitor_hash.present? || network_hash.present?

    errors.add(:base, 'requires a signed-in user or a pseudonymous visitor identifier')
  end

  def has_supported_client_context
    return if client_context.blank?
    return unless client_context.is_a?(Hash)

    allowed_keys = %w[device_class browser_family browser_major os_family viewport_bucket beacon fetch webp avif save_data connection_type]
    errors.add(:client_context, 'contains unsupported values') unless client_context.keys.all? { |key| allowed_keys.include?(key.to_s) }
  end

  def has_supported_event_context
    return if event_context.blank?
    return unless event_context.is_a?(Hash)

    allowed_keys = %w[surface list_mode filter_signature rank ranking_version page]
    errors.add(:event_context, 'contains unsupported values') unless event_context.keys.all? { |key| allowed_keys.include?(key.to_s) }
  end
end
