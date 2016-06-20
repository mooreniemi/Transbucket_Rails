class PinFilterQuery
  attr_accessor :pins
  attr_accessor :procedures, :surgeons, :general

  def initialize(keywords)
    @procedures = keywords[:procedure]
    @surgeons = keywords[:surgeon]
    @general = format_scope(keywords.fetch(:scope,nil))
  end

  def filtered
    if surgeons.present? && procedures.present?
      if general.present?
        args = general.join('.')
        Rails.cache.fetch("very_specific:" + args + [surgeons + procedures].join(',')) do
          Pin.instance_eval { eval args }.by_surgeon([surgeons]).by_procedure([procedures])
        end
      else
        Rails.cache.fetch("surgeons_by_procedures:" + [surgeons + procedures].join(',')) do
          Pin.by_surgeon([surgeons]).by_procedure([procedures])
        end
      end
    elsif surgeons.present?
      Rails.cache.fetch("surgeons:" + [surgeons].join(',')) do
        Pin.by_surgeon([surgeons])
      end
    elsif procedures.present?
      Rails.cache.fetch("procedures:" + [procedures].join(',')) do
        Pin.by_procedure([procedures])
      end
    elsif general.present?
      args = general.join('.')
      Rails.cache.fetch("search_terms:" + args) do
        Pin.instance_eval { eval args }
      end
    else
      Pin.none
    end
  end

  private

  def format_scope(scope)
    return if scope.nil?
    scope.collect!(&:parameterize).collect!(&:underscore).collect!(&:to_sym)
    scope
  end
end
