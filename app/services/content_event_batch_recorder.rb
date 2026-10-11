require 'openssl'

class ContentEventBatchRecorder
  MAX_BATCH_SIZE = 50
  # The cards in the feed: submissions, standalone discussions, and procedure
  # or surgeon discussions (their opening Comment).
  IMPRESSION_TYPES = %w[Pin Discussion Comment].freeze

  def self.record_impressions(attributes)
    new(**attributes).record_impressions
  end

  def initialize(request:, current_user:, locale:, visitor_id:, client_context:, events:)
    @request = request
    @current_user = current_user
    @locale = locale
    @visitor_id = visitor_id
    @client_context = client_context.respond_to?(:to_h) ? client_context.to_h : {}
    @events = Array(events).first(MAX_BATCH_SIZE)
  end

  def record_impressions
    candidates = valid_candidates
    return 0 if candidates.empty?

    ContentEvent.transaction do
      ContentEvent.connection.execute("SET LOCAL statement_timeout = '#{ContentEventRecorder::STATEMENT_TIMEOUT}'")
      existing = existing_impressions(candidates)
      candidates.reject { |event| existing.include?([event[:content_type], event[:content_id]]) }.each do |event|
        ContentEvent.create!(base_attributes.merge(content_type: event[:content_type], content_id: event[:content_id], event_context: event[:event_context]))
      end
    end
    candidates.length
  rescue StandardError => error
    Rails.logger.warn("content event batch recording failed: #{error.class}")
    0
  end

  private

  def valid_candidates
    wanted = @events.select do |event|
      IMPRESSION_TYPES.include?(event[:content_type]) && event[:event_type] == 'impression' && event[:content_id].to_s.match?(/\A[1-9]\d*\z/)
    end
    existing = wanted.group_by { |event| event[:content_type] }.flat_map do |type, events|
      type.constantize.where(id: events.map { |event| event[:content_id].to_i }).pluck(:id).map { |id| [type, id] }
    end
    seen = {}
    wanted.each_with_object([]) do |event, candidates|
      key = [event[:content_type], event[:content_id].to_i]
      next unless existing.include?(key) && !seen[key]

      context = event[:event_context].respond_to?(:to_h) ? event[:event_context].to_h.stringify_keys : {}
      candidates << { content_type: key[0], content_id: key[1], event_context: context.slice(*%w[surface list_mode filter_signature rank ranking_version page]) }
      seen[key] = true
    end
  end

  # [content_type, content_id] pairs already recorded within the window.
  def existing_impressions(candidates)
    candidates.group_by { |event| event[:content_type] }.flat_map do |type, events|
      scope = ContentEvent.where(content_type: type, content_id: events.map { |event| event[:content_id] }, event_type: 'impression').where('occurred_at >= ?', ContentEventRecorder::DEDUPLICATION_WINDOW.ago)
      scope = @current_user ? scope.where(user_id: @current_user.id) : scope.where(visitor_hash: visitor_hash)
      scope.pluck(:content_id).map { |id| [type, id] }
    end
  end

  def base_attributes
    attributes = { event_type: 'impression', source: 'client', locale: @locale.to_s, client_context: @client_context, occurred_at: Time.current }
    if @current_user
      attributes[:user] = @current_user
    else
      attributes[:visitor_hash] = visitor_hash
      attributes[:network_hash] = network_hash
    end
    attributes
  end

  def visitor_hash
    @visitor_hash ||= hmac(@visitor_id)
  end

  def network_hash
    @network_hash ||= hmac("#{Date.current.iso8601}:#{@request.remote_ip}")
  end

  def hmac(value)
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, value)
  end
end
