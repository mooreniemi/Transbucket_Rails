# Records a server-side content event when someone submits or edits a pin,
# posts a standalone discussion or comments (a discussion reply included), so that step sits in content_events next to
# the browser's impression/open/view events. Called only after it has saved.
#
# Tracking must never get in the way of a submission: the insert runs in its
# own short transaction with the same statement timeout as
# ContentEventRecorder, and any failure is logged and swallowed.
class SubmissionEventRecorder
  # Which kind of record each event is about.
  EVENT_TYPES = {
    'submission_created' => 'Pin',
    'submission_updated' => 'Pin',
    'discussion_created' => 'Discussion',
    'comment_created' => 'Comment'
  }.freeze

  def self.record(user:, event_type:, locale:, pin: nil, content: pin)
    return false unless content&.persisted? && user.present? && EVENT_TYPES[event_type] == content.class.name

    ContentEvent.transaction do
      ContentEvent.connection.execute("SET LOCAL statement_timeout = '#{ContentEventRecorder::STATEMENT_TIMEOUT}'")
      ContentEvent.create!(
        user: user,
        content_type: content.class.name,
        content_id: content.id,
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
