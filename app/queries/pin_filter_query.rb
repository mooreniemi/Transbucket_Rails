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
      Pin.by_surgeon([surgeons])
    elsif procedures.present?
      Pin.by_procedure([procedures])
    elsif general.present?
      # TODO eval of string is bad news
      args = general.join('.')
      Pin.instance_eval{eval args}
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
