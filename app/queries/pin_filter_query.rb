class PinFilterQuery
  VALID_FILTERS = [:procedures, :surgeons, :general, :complications]
  PERMITTED_SCOPES = [:ftm, :mtf, :top, :bottom, :need_category]
  attr_reader(*VALID_FILTERS)
  attr_accessor :pins

  def initialize(keywords)
    @procedures = keywords[:procedure]
    @surgeons = keywords[:surgeon]
    @complications = add_default(keywords[:complication])
    @general = format_scope(keywords.fetch(:scope,nil))
  end

  def filtered
    args = general.present? ? general.join('.') : 'Pin'
    Rails.cache.fetch(cache_key) do
      Pin.instance_eval { eval args }.
        tagged_with(*complications).
        by_procedure(procedures).
        by_surgeon(surgeons).
        recent
    end
  end

  private

  def cache_key
    active_filters = []
    keywords = []

    VALID_FILTERS.each do |filter|
      next if send(filter).nil?
      keywords << send(filter)
      active_filters << filter
    end

    "#{active_filters.zip(keywords)}"
  end

  def add_default(complication_params)
    complication_params.nil? ? [['SENTINEL'], exclude: true] : complication_params
  end

  def format_scope(scope)
    return if scope.nil?
    scope.collect!(&:parameterize).
      collect!(&:underscore).
      collect!(&:to_sym).
      collect! {|s| s if PERMITTED_SCOPES.include?(s) }
  end
end
