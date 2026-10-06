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

  # The hidden marker that records a feed card's impression when the page (or
  # the next page of the feed) shows it; see content_events.js. Submission
  # cards (pins/_pin) write theirs out by hand.
  def content_event_impression_marker(content_type, content_id, context = {})
    content_event_marker(content_type, content_id, 'impression', context)
  end

  # The same for a page that is one piece of content (a discussion's page,
  # also when the phone viewer opens it), recorded as a view.
  def content_event_view_marker(content_type, content_id)
    content_event_marker(content_type, content_id, 'view')
  end

  def content_event_marker(content_type, content_id, event_type, context = {})
    content_tag :div, '', hidden: true, 'data-content-event' => true,
      'data-content-event-url' => content_events_path,
      'data-content-event-batch-url' => batch_content_events_path,
      'data-content-type' => content_type,
      'data-content-id' => content_id,
      'data-event-type' => event_type,
      'data-event-context' => context.to_json
  end

  # Attributes that record a click on an allowlisted navigation target (see
  # TrackedTarget), e.g. link_to 'News', newsfeed_path, track_click_attributes(:news, :header)
  def track_click_attributes(target, surface)
    content_event_open_attributes('Page', TrackedTarget.id_for(target), surface: surface.to_s, target: target.to_s)
  end

  # The same as an HTML attribute string, for hand-written <a> and <button> tags.
  def track_click_attribute_string(target, surface)
    track_click_attributes(target, surface).map { |name, value| %(#{name}="#{ERB::Util.html_escape(value)}") }.join(' ').html_safe
  end
end
