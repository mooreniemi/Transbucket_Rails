class PinPresenter
  attr_accessor :query, :user, :safe_mode

  def initialize(opts = {})
    @page = opts.fetch(:page) if opts[:page].present?
    @user = opts.fetch(:user) { nil } if opts[:user].present?
    @safe_mode = @user.preference.present? ? UserPolicy.new(@user).safe_mode? : false
    @query = opts.fetch(:query) { [] } if opts[:query].present?
    @scope = get_scope(opts.fetch(:scope)) if opts[:scope].present?
  end

  def each(&block)
    @pins.each(&block)
  end

  def all_pins
    @pins = @query.blank? ? Pin.recent.paginate(:page => @page) : Pin.search(@query, :page => @page, :per_page => 20)
    unless @scope == [:all]
      @general.each {|s| @pins = @pins.send(s)} if @general.present?
      @procedures.each {|p| @pins = @pins.by_procedure(p)} if @procedures.present?
      @surgeons.each {|s| @pins = @pins.by_surgeon(s.titleize)} if @surgeons.present?
    end
    @pins.reject! {|p| p.nil? }
    return @pins
  end

  def by_user(user)
    @pins = Pin.by_user(user).paginate(:page => @page)
  end

  def show_new_comments(pin)
    @sign_in = User.find(@user).last_sign_in_at
    @comments = Comment.where('created_at > ? and commentable_id = ?', @sign_in, pin.id)
  end

  def scopes
    [["General Filters", Pin::SCOPES.map(&:humanize)], ["By Procedure", Procedure.pluck(:name).sort], ["By Surgeon", Surgeon.names]]
  end

  def get_scope(scope)
    return [:all] if scope.empty?
    scope.collect!(&:downcase)
    @procedures = []
    @surgeons = []
    @general = []
    scope.each {|s| @procedures << s if Procedure.pluck(:name).map(&:downcase).include?(s) }
    scope.each {|s| @surgeons << s if Surgeon.names.map(&:downcase).include?(s) }
    @general = scope - @procedures - @surgeons
    @general.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym) if @general.present?
    scope
  end

end