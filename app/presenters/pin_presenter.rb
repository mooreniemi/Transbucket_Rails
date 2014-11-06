class PinPresenter
  attr_accessor :query, :page, :filter, :pins
  attr_accessor :user, :procedures, :surgeons, :general

  def initialize(opts = {})
    Pin.includes(:comments) # TODO only improves from 1500 ms to 1200 :c

    @page = opts.delete(:page)
    @query = opts.delete(:query)
    @user = opts.delete(:user)
    @filter = opts

    @pins = if @query.present?
      Pin.search(@query, :page => @page, :per_page => 20)
    elsif @user.present?
      Pin.by_user(@user).paginate(:page => @page)
    elsif has_keywords?
      PinFilterQuery.new(filter).filtered
    else
      Pin.recent.paginate(:page => @page)
    end
  end

  def all
    pins.uniq!
  end

  private

  def has_keywords?
    filter.values.reject(&:nil?).count > 0
  end
end
