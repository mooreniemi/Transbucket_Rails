class Procedure < ActiveRecord::Base
  include Stats
  include CommentsHelper
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills
  has_many :translations, class_name: 'ProcedureTranslation', dependent: :destroy

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  # all procedures are stored lowercase
  before_save { self.name.downcase! }

  # but when we validate the incoming record we compare case insensitive
  # because we haven't downcased incoming string yet
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def to_s
    localized_name
  end

  def localized_name(locale = I18n.locale)
    return name unless ProcedureTranslation.table_exists?

    translation = translations.detect { |candidate| candidate.locale == locale.to_s }
    translation ? translation.name : name
  end

  def editorial_guide
    self.class.editorial_guides[name]
  end

  # Editorial links come first; token matches fill gaps for variants such as
  # "laparoscopic hysterectomy" and "groin flap phalloplasty".
  # Procedures a user counts as having posted about, for discussions shown to
  # "people who posted about X": the ones they published submissions for, plus
  # those procedures' related ones (so an RFF phalloplasty submission covers
  # phalloplasty). Memoized on the user for the request.
  def self.covered_ids_for(user)
    return [] if user.blank?
    return user.instance_variable_get(:@covered_procedure_ids) if user.instance_variable_defined?(:@covered_procedure_ids)

    posted = Pin.where(user_id: user.id, state: 'published').where.not(procedure_id: nil).distinct.pluck(:procedure_id)
    related = where(id: posted).flat_map { |procedure| procedure.related_procedures.map(&:id) }
    user.instance_variable_set(:@covered_procedure_ids, (posted + related).uniq)
  end

  def related_procedures
    explicit_names = (editorial_guide || {}).fetch('related_procedures', [])
    explicit = self.class.where(name: explicit_names).to_a
    related = self.class.where.not(id: id).to_a.select do |procedure|
      (procedure_relation_tokens & self.class.procedure_relation_tokens(procedure.name)).any?
    end

    (explicit + related).uniq { |procedure| procedure.id }
  end

  def self.editorial_guides
    @editorial_guides ||= YAML.load_file(Rails.root.join('config', 'procedure_guides.yml')).freeze
  end

  def self.names
    self.pluck(:name).sort
  end

  def self.procedure_relation_tokens(procedure_name)
    procedure_name.to_s.downcase.gsub(/[^a-z0-9]+/, ' ').split.reject do |token|
      %w(and with without the for into from via no other surgery procedure).include?(token)
    end
  end

  # Search aliases are editorial data, not alternate procedure records. Keep
  # the canonical procedure name unchanged while allowing localized searches.
  def search_aliases
    return editorial_aliases unless ProcedureTranslation.table_exists?

    translated_names = translations.map(&:name)
    (translated_names + editorial_aliases).compact.uniq
  end

  private

  def procedure_relation_tokens
    self.class.procedure_relation_tokens(name)
  end

  def editorial_aliases
    ApplicationController::SUPPORTED_LOCALES.flat_map do |locale|
      aliases = I18n.t(:procedure_aliases, locale: locale, default: {})
      aliases[name] || aliases[name.to_sym] || []
    end.compact.uniq
  end
end
