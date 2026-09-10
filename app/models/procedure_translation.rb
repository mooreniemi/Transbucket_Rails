class ProcedureTranslation < ActiveRecord::Base
  belongs_to :procedure

  validates :procedure, presence: true
  validates :locale, presence: true, inclusion: { in: ->(_record) { I18n.available_locales.map(&:to_s) } }
  validates :name, presence: true, uniqueness: { scope: [:procedure_id, :locale] }
  validates :procedure_id, uniqueness: { scope: :locale }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip.downcase.presence
  end
end
