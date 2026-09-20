module ContentEventsHelper
  # Data attributes that make a link record an "open" event when clicked
  # (see content_events.js). +context+ is the allowlisted event_context.
  def content_event_open_attributes(content_type, content_id, context = {})
    {
      'data-content-event-open' => true,
      'data-content-event-url' => content_events_path,
      'data-content-type' => content_type,
      'data-content-id' => content_id,
      'data-event-context' => context.to_json
    }
  end
end
