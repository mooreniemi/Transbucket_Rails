class PinPresenter
  attr_accessor :query, :user, :safe_mode

  def initialize(opts = {})
    @page = opts.fetch(:page) if opts[:page].present?
    @user = opts.fetch(:user) { nil } if opts[:user].present?
    @safe_mode = @user.preference.present? ? UserPolicy.new(@user).safe_mode? : false
    @query = opts.fetch(:query) { [] } if opts[:query].present?
    @scope = opts[:scope].present? ? opts.fetch(:scope).map(&:parameterize) : ['all']
  end

  def each(&block)
    @pins.each(&block)
  end

  def all_pins
    @scope.collect! {|e| e.to_sym }
    @pins = @query.blank? ? Pin.recent.paginate(:page => @page) : Pin.search(@query, :page => @page, :per_page => 20)
    @scope.each {|s| @pins = @pins.send(s)}
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

end

#@pins = query.blank? ? Pin.where(state: 'published').order("created_at desc").paginate(:page => params[:page]) : Pin.search(query, :page => params[:page], :per_page => 20)
