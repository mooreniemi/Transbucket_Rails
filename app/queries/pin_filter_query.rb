class PinFilterQuery
  attr_accessor :pins
  VALID_FILTERS = [:procedures, :surgeons, :general, :complications]
  PERMITTED_SCOPES = [:ftm, :mtf, :top, :bottom, :need_category]
  attr_reader(*VALID_FILTERS)

  def initialize(keywords)
    @procedures = keywords[:procedure]
    @surgeons = keywords[:surgeon]
    @complications = add_default(keywords[:complication])
    @general = format_scope(keywords.fetch(:scope,nil))
  end

  def filtered
    active_filters = []
    keywords = []
    VALID_FILTERS.each do |filter|
      next if send(filter).nil?
      keywords << send(filter)
      active_filters << filter
    end

    # this will make the instance_eval a no-op
    args = general.present? ? general.join('.') : 'Pin'
    Rails.cache.fetch(cache_key_for(active_filters, keywords)) do
      # FIXME not crazy about eval here, how can we make sure this is safe from delete
      Pin.includes(:user, :pin_images, :surgeon, :procedure).instance_eval { eval args }.
        tagged_with(*complications).
        by_procedure([procedures].flatten).
        by_surgeon([surgeons].flatten).
        recent
    end
  end

  private

  def cache_key_for(active_filters, keywords)
    "#{active_filters.zip(keywords)}"
  end

  def add_default(complication_params)
    complication_params.nil? ? [['SENTINEL'], exclude: true] : complication_params
  end

  def format_scope(scope)
    return if scope.nil?
    scope.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym).
      collect! {|s| s if PERMITTED_SCOPES.include?(s) }
    scope
  end
end
