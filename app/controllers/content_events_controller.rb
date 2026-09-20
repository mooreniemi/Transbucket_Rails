class ContentEventsController < ApplicationController
  # The beacon API cannot attach Rails' CSRF header. This endpoint accepts a
  # tiny allowlisted payload and has no user-visible effect, so it always
  # responds with 204 whether recording succeeds or is intentionally skipped.
  skip_before_action :verify_authenticity_token, only: [:create, :batch]

  def create
    ContentEventRecorder.record(
      request: request,
      current_user: current_user,
      locale: I18n.locale,
      content_type: params[:content_type],
      content_id: params[:content_id],
      event_type: params[:event_type],
      visitor_id: anonymous_visitor_id,
      client_context: client_context,
      event_context: event_context
    )
  rescue StandardError => error
    Rails.logger.warn("content event request failed: #{error.class}: #{error.message}")
  ensure
    head :no_content unless performed?
  end

  def batch
    ContentEventBatchRecorder.record_impressions(
      request: request,
      current_user: current_user,
      locale: I18n.locale,
      visitor_id: anonymous_visitor_id,
      client_context: client_context,
      events: batch_events
    )
  rescue StandardError => error
    Rails.logger.warn("content event batch request failed: #{error.class}: #{error.message}")
  ensure
    head :no_content unless performed?
  end

  private

  def anonymous_visitor_id
    return if current_user

    visitor_id = cookies.signed[:content_event_visitor_id] || SecureRandom.uuid
    cookies.signed[:content_event_visitor_id] = {
      value: visitor_id,
      expires: 7.days.from_now,
      httponly: true
    }
    visitor_id
  end

  def client_context
    allowlisted_context(:client_context, %w[device_class browser_family browser_major os_family viewport_bucket beacon fetch webp avif save_data connection_type])
  end

  def event_context
    allowlisted_context(:event_context, %w[surface list_mode filter_signature rank ranking_version page target])
  end

  def batch_events
    raw_events = params[:events]
    raw_events = raw_events.values if raw_events.respond_to?(:values)
    Array(raw_events).map do |event|
      event = event.to_unsafe_h if event.respond_to?(:to_unsafe_h)
      event = event.to_h if event.respond_to?(:to_h)
      event.slice(*%w[content_type content_id event_type event_context]).symbolize_keys
    end
  end

  def allowlisted_context(name, keys)
    context = params[name]
    return {} unless context

    context = context.to_unsafe_h if context.respond_to?(:to_unsafe_h)
    return {} unless context.respond_to?(:to_h)

    context.to_h.slice(*keys)
  end
end
