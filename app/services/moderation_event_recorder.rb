class ModerationEventRecorder
  def self.record(action:, user:, content:)
    ModerationEvent.create!(
      action: action.to_s,
      user: user,
      content_type: content.class.base_class.name,
      content_id: content.id,
      occurred_at: Time.current
    )
  rescue StandardError => error
    Rails.logger.warn("moderation event recording failed: #{error.class}")
    nil
  end
end
