class PinPresenter
  PERSONALIZED_FEED_GENDERS = %w[MTF FTM].freeze

  # What a feed card reads from each pin. Loading these up front keeps the query
  # count flat as the page fills (it used to add four per card: the images, the
  # surgeon, the procedure and the procedure's translations).
  CARD_INCLUDES = [:user, :pin_images, :surgeon, { procedure: :translations }].freeze

  attr_accessor :query, :page, :filter, :pins, :feed
  attr_accessor :user, :procedures, :surgeons, :general

  def initialize(opts = {})
    @page = opts.delete(:page)
    @query = opts.delete(:query)
    @user = opts.delete(:user)
    @current_user = opts.delete(:current_user)
    @feed = opts.delete(:feed)
    @filter = opts

    @pins = if @query.present?
              begin
                search_results = Pin.search(PinSearchQuery.all_xfields(@query), PinSearchQuery::DEFAULT_OPTIONS)
                                     .paginate(page: @page)
                search_records = search_results.records
                search_records.to_a
                search_records
              rescue Elasticsearch::Transport::Transport::Errors::NotFound,
                     Elasticsearch::Transport::Transport::Errors::ServiceUnavailable,
                     Elasticsearch::Transport::Transport::Errors::GatewayTimeout,
                     Elasticsearch::Transport::Transport::Errors::BadGateway,
                     Faraday::ConnectionFailed,
                     Faraday::TimeoutError => e
                Rails.logger.warn("Elasticsearch search unavailable for PinPresenter: #{e.class}: #{e.message}")
                Pin.includes(:user).recent.paginate(page: @page)
              end
            elsif @user.present?
              Pin.includes(*CARD_INCLUDES).by_user(@user).paginate(:page => @page)
            elsif has_keywords?
              # includes are handled inside Query object
              PinFilterQuery.new(filter).filtered.paginate(:page => @page)
            else
              feed_scope.includes(*CARD_INCLUDES).recent.paginate(:page => @page)
            end
  end

  def personalized_feed_available?
    PERSONALIZED_FEED_GENDERS.include?(@current_user.try(:gender).try(:name))
  end

  def showing_for_you?
    browsing_feed? && @feed == 'for_you' && personalized_feed_available?
  end

  def show_feed_navigation?
    browsing_feed? && personalized_feed_available?
  end

  def list_event_context
    {
      surface: 'pins_index',
      list_mode: list_mode,
      filter_signature: active_filter_names.join(','),
      ranking_version: ranking_version,
      page: current_page
    }
  end

  # 1-based page being shown (a missing or invalid page param means page 1).
  def current_page
    [@page.to_i, 1].max
  end

  # Number of pins on earlier pages, so ranks keep counting up across pages
  # (page 2 starts at 31, not back at 1) and opens can be compared by depth.
  def rank_offset
    (current_page - 1) * Pin.per_page
  end

  private

  def feed_scope
    showing_for_you? ? Pin.by_user_gender(@current_user) : Pin
  end

  def browsing_feed?
    @query.blank? && @user.blank? && !has_keywords?
  end

  def list_mode
    return 'search' if @query.present?
    return 'user' if @user.present?
    return 'filtered' if has_keywords?
    return 'for_you' if showing_for_you?

    'recent'
  end

  def active_filter_names
    @filter.each_with_object([]) do |(name, value), active|
      active << name.to_s if value.present?
    end.sort
  end

  def ranking_version
    {
      'recent' => 'recent_submission_activity_v1',
      'for_you' => 'for_you_gender_v1',
      'search' => 'search_v1',
      'filtered' => 'filtered_recent_activity_v1',
      'user' => 'user_submissions_v1'
    }.fetch(list_mode)
  end

  def has_keywords?
    filter.values.reject(&:nil?).count > 0
  end
end
