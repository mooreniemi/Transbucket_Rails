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
    else
      Pin.recent.paginate(:page => @page)
    end
  end

  def all
    build_query if has_keywords?
    pins.uniq!
  end

  private
  def build_query
    set_keywords

    if surgeons.present?
      [surgeons].each {|s| @pins = @pins.by_surgeon(s)}
    elsif procedures.present?
      [procedures].each {|p| @pins = @pins.by_procedure(p)}
    else
      general.each {|s| @pins = @pins.send(s)}
    end
  end

  def format_scope(scope)
    return if scope.nil?
    scope.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym)
    scope
  end

  def has_keywords?
    filter.values.reject(&:nil?).count > 0
  end

  def set_keywords
    @user = filter[:user]
    @procedures = filter[:procedure]
    @surgeons = filter[:surgeon]
    @general = format_scope(filter.fetch(:scope,nil))
  end
end
