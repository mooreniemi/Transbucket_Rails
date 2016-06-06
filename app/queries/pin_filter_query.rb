class PinFilterQuery
  attr_accessor :pins
  attr_accessor :procedures, :surgeons, :general

  def initialize(keywords)
    @procedures = keywords[:procedure]
    @surgeons = keywords[:surgeon]
    @general = format_scope(keywords.fetch(:scope,nil))
  end

  def filtered
    if surgeons.present?
      Rails.cache.fetch("surgeons" + [surgeons].join(',')) do
        Pin.by_surgeon([surgeons])
      end
    elsif procedures.present?
      Rails.cache.fetch("procedures" + [procedures].join(',')) do
        Pin.by_procedure([procedures])
      end
    elsif general.present?
      args = general.join('.')
      Rails.cache.fetch(args) do
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
