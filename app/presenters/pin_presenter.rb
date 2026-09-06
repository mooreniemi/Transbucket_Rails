class PinPresenter
  attr_accessor :query, :page, :filter, :pins
  attr_accessor :user, :procedures, :surgeons, :general

  def initialize(opts = {})
    @page = opts.delete(:page)
    @query = opts.delete(:query)
    @user = opts.delete(:user)
    @current_user = opts.delete(:current_user)
    @filter = opts

    @pins = if @query.present?
              begin
                Pin.search(PinSearchQuery.all_xfields(@query), PinSearchQuery::DEFAULT_OPTIONS)
                   .paginate(page: @page)
                   .records
                   .to_a
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
              Pin.includes(:user, :pin_images, :procedure, :surgeon).by_user(@user).paginate(:page => @page)
            elsif has_keywords?
              # includes are handled inside Query object
              PinFilterQuery.new(filter).filtered.paginate(:page => @page)
            else
              # NOTE: if we want to do by_user_gender, we'd do it here
              # but there's not an easy way to let people change this on the fly
              Pin.includes(:user).recent.paginate(:page => @page)
            end
  end

  private
  def has_keywords?
    filter.values.reject(&:nil?).count > 0
  end
end
