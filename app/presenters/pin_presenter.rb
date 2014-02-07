class PinPresenter
  attr_accessor :query, :user, :safe_mode, :query, :procedures, :surgeons, :page, :general

  def initialize(opts = {})
    @page = opts.fetch(:page) if opts[:page].present?
    @current_user = opts.fetch(:current_user) if opts[:current_user].present?
    @safe_mode = @current_user.preference.present? ? UserPolicy.new(@current_user).safe_mode? : false

    @query = opts.fetch(:query) { [] } if opts[:query].present?

    @user = opts.fetch(:user) if opts[:user].present?
    @procedures = [opts.fetch(:procedure)] if opts[:procedure].present?
    @surgeons = [opts.fetch(:surgeon)] if opts[:surgeon].present?
    @general = get_scope(opts.fetch(:scope)) if opts[:scope].present?
  end

  def each(&block)
    pins.each(&block)
  end

  def all
    pins = query.blank? ? Pin.recent.paginate(:page => page) : Pin.search(query, :page => page, :per_page => 20)
    pins = Pin.by_user(user).paginate(:page => page) if user.present?

    general.each {|s| pins = pins.send(s)} if general.present?
    procedures.each {|p| pins = pins.by_procedure(p)} if procedures.present?
    surgeons.each {|s| pins = pins.by_surgeon(s)} if surgeons.present?

    pins.reject! {|p| p.nil? }
    pins
  end

  def show_new_comments(pin)
    sign_in = User.find(user).last_sign_in_at
    comments = Comment.where('created_at > ? and commentable_id = ?', sign_in, pin.id)
  end

  def scopes
    [["General Filters", Pin::SCOPES.map(&:humanize)]]
  end

  def get_scope(scope)
    return [:all] if scope.empty?

    general = [scope - procedures - surgeons]
    return general.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym) if general.present?
  end

end