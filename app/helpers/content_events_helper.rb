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
