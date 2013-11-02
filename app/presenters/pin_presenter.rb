class PinPresenter
  attr_accessor :query, :user, :safe_mode

  def initialize(opts = {})
    @page = opts.fetch(:page)
    @user = opts.fetch(:user) { nil }
    @safe_mode = opts.fetch(:safe_mode)
    @query = opts.fetch(:query) { [] }
    @scope = opts[:scope].present? ? opts.fetch(:scope) : 'all'
  end

  def each(&block)
    @pins.each(&block)
  end

  def all_pins
    @pins = @query.blank? ? Pin.where(state: 'published').order("created_at desc").paginate(:page => @page).send(@scope) : Pin.search(@query, :page => @page, :per_page => 20)
    @pins.reject! {|p| p.nil? }
    return @pins
  end

  def show_new_comments(pin)
    @sign_in = User.find(@user).last_sign_in_at
    @comments = Comment.where('created_at > ? and commentable_id = ?', @sign_in, pin.id)
  end

end

#@pins = query.blank? ? Pin.where(state: 'published').order("created_at desc").paginate(:page => params[:page]) : Pin.search(query, :page => params[:page], :per_page => 20)
