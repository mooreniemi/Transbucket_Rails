require 'openssl'

class ContentEventRecorder
  DEDUPLICATION_WINDOW = 30.minutes
  STATEMENT_TIMEOUT = '100ms'.freeze
  TRACKED_CONTENT_TYPES = %w[Pin Procedure Surgeon].freeze
  TRACKED_EVENT_TYPES = %w[impression open view].freeze

  def self.record(attributes)
    new(**attributes).record
  end

  def initialize(request:, current_user:, locale:, content_type:, content_id:, event_type:, visitor_id:, client_context: {}, event_context: {})
    @request = request
    @current_user = current_user
    @locale = locale
    @content_type = content_type
    @content_id = content_id
    @event_type = event_type
    @visitor_id = visitor_id
    @client_context = client_context.respond_to?(:to_h) ? client_context.to_h : {}
    @event_context = event_context.respond_to?(:to_h) ? event_context.to_h : {}
  end

  def record
    return false unless valid_target?

    event = ContentEvent.transaction do
      ContentEvent.connection.execute("SET LOCAL statement_timeout = '#{STATEMENT_TIMEOUT}'")
      duplicate? ? nil : ContentEvent.create!(event_attributes)
    end
    event.present?
  rescue StandardError => error
    Rails.logger.warn("content event recording failed: #{error.class}")
    false
  end

  private

  def valid_target?
    TRACKED_CONTENT_TYPES.include?(@content_type) &&
      TRACKED_EVENT_TYPES.include?(@event_type) &&
      @content_id.to_s.match?(/\A[1-9]\d*\z/) &&
      (@current_user.present? || @visitor_id.present?) &&
      content_class.exists?(@content_id)
  end

  def content_class
    @content_type.constantize
  end

  def duplicate?
    scope = ContentEvent.where(
      content_type: @content_type,
      content_id: @content_id,
      event_type: @event_type
    ).where('occurred_at >= ?', DEDUPLICATION_WINDOW.ago)
    scope = if @current_user
      scope.where(user_id: @current_user.id)
    else
      scope.where(visitor_hash: visitor_hash)
    end
    scope.exists?
  end

  def event_attributes
    attributes = {
      content_type: @content_type,
      content_id: @content_id,
      event_type: @event_type,
      source: 'client',
      locale: @locale.to_s,
      client_context: @client_context,
      event_context: @event_context,
      occurred_at: Time.current
    }
    if @current_user
      attributes[:user] = @current_user
    else
      attributes[:visitor_hash] = visitor_hash
      attributes[:network_hash] = network_hash
    end
    attributes
  end

  def visitor_hash
    hmac(@visitor_id)
  end

  def network_hash
    hmac("#{Date.current.iso8601}:#{@request.remote_ip}")
  end

  def hmac(value)
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secrets.secret_key_base, value)
  end
end
