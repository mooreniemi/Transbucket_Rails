require 'openssl'

class ContentEventBatchRecorder
  MAX_BATCH_SIZE = 50

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
      existing_ids = existing_impression_ids(candidates.map { |event| event[:content_id] })
      candidates.reject { |event| existing_ids.include?(event[:content_id]) }.each do |event|
        ContentEvent.create!(base_attributes.merge(content_id: event[:content_id], event_context: event[:event_context]))
      end
    end
    candidates.length
  rescue StandardError => error
    Rails.logger.warn("content event batch recording failed: #{error.class}")
    0
  end

  private

  def valid_candidates
    ids = @events.select { |event| event[:content_type] == 'Pin' && event[:event_type] == 'impression' && event[:content_id].to_s.match?(/\A[1-9]\d*\z/) }.map { |event| event[:content_id].to_i }
    existing_ids = Pin.where(id: ids).pluck(:id)
    seen_ids = {}
    @events.each_with_object([]) do |event, candidates|
      id = event[:content_id].to_i
      next unless existing_ids.include?(id) && !seen_ids[id]

      context = event[:event_context].respond_to?(:to_h) ? event[:event_context].to_h.stringify_keys : {}
      candidates << { content_id: id, event_context: context.slice(*%w[surface list_mode filter_signature rank ranking_version]) }
      seen_ids[id] = true
    end
  end

  def existing_impression_ids(ids)
    scope = ContentEvent.where(content_type: 'Pin', content_id: ids, event_type: 'impression').where('occurred_at >= ?', ContentEventRecorder::DEDUPLICATION_WINDOW.ago)
    scope = @current_user ? scope.where(user_id: @current_user.id) : scope.where(visitor_hash: visitor_hash)
    scope.pluck(:content_id)
  end

  def base_attributes
    attributes = { content_type: 'Pin', event_type: 'impression', source: 'client', locale: @locale.to_s, client_context: @client_context, occurred_at: Time.current }
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
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secrets.secret_key_base, value)
  end
end
