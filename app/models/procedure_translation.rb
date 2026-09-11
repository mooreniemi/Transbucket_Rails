class ProcedureTranslation < ActiveRecord::Base
  belongs_to :procedure

  validates :procedure, presence: true
  validates :locale, presence: true, inclusion: { in: ->(_record) { ApplicationController::SUPPORTED_LOCALES } }
  validates :name, presence: true, uniqueness: { scope: [:procedure_id, :locale], case_sensitive: false }
  validates :procedure_id, uniqueness: { scope: :locale }

  before_validation :normalize_name

  private

  # Only whitespace is stripped -- casing is preserved because this name is
  # rendered directly as page heading text via Procedure#localized_name, and
  # many locales (German nouns, for one) are case-sensitive. Search matching
  # doesn't need this column downcased: the Elasticsearch analyzers already
  # lowercase tokens at index and query time regardless of stored casing.
  def normalize_name
    self.name = name.to_s.strip.presence
  end
end
