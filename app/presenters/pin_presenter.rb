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
      Pin.includes(:user, :pin_images, :procedure, :surgeon).search(@query, :page => @page, :per_page => 20)
    elsif @user.present?
      Pin.includes(:user, :pin_images, :procedure, :surgeon).by_user(@user).paginate(:page => @page)
    elsif has_keywords?
      PinFilterQuery.new(filter).filtered.paginate(:page => @page)
    else
      Pin.includes(:user, :pin_images, :procedure, :surgeon).recent.paginate(:page => @page)
    end
  end

  private
  def has_keywords?
    filter.values.reject(&:nil?).count > 0
  end
end
