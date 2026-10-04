# Records a server-side content event when someone submits or edits a pin, so
# the submission step sits in content_events next to the browser's
# impression/open/view events. Called only after the pin has been saved.
#
# Tracking must never get in the way of a submission: the insert runs in its
# own short transaction with the same statement timeout as
# ContentEventRecorder, and any failure is logged and swallowed.
class SubmissionEventRecorder
  EVENT_TYPES = %w[submission_created submission_updated].freeze

  def self.record(pin:, user:, event_type:, locale:)
    return false unless EVENT_TYPES.include?(event_type) && pin&.persisted? && user.present?

    ContentEvent.transaction do
      ContentEvent.connection.execute("SET LOCAL statement_timeout = '#{ContentEventRecorder::STATEMENT_TIMEOUT}'")
      ContentEvent.create!(
        user: user,
        content_type: 'Pin',
        content_id: pin.id,
        event_type: event_type,
        source: 'server',
        locale: locale.to_s,
        occurred_at: Time.current
      )
    end
    true
  rescue StandardError => error
    Rails.logger.warn("submission event recording failed: #{error.class}")
    false
  end
end
