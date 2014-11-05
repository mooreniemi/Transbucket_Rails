class PinPresenter
  using SafeFetch
  attr_accessor :query, :user, :query, :procedures, :surgeons, :page, :general

  def initialize(opts = {})
    @page = opts.safe_fetch(:page)

    @query = opts.safe_fetch(:query) { [] }

    @user = opts.safe_fetch(:user)
    @procedures = [opts.safe_fetch(:procedure)]
    @surgeons = [opts.safe_fetch(:surgeon)]

    @general = format_scope(opts.safe_fetch(:scope)) if opts[:scope].present?
  end

  def all
    Pin.includes(:comments) # TODO only improves from 1500 ms to 1200 :c
    pins = query.blank? ? Pin.recent.paginate(:page => page) : Pin.search(query, :page => page, :per_page => 20)

    pins = Pin.by_user(user).paginate(:page => page) if user.present?
    general.each {|s| pins = pins.send(s)} if general.present?

    procedures.each {|p| pins = pins.by_procedure(p)} if procedures.present?
    surgeons.each {|s| pins = pins.by_surgeon(s)} if surgeons.present?

    pins.uniq!
    pins
  end

  private
  def format_scope(scope)
    scope.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym)
    scope
  end
end