class Procedure < ActiveRecord::Base
  include Stats
  include CommentsHelper
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  # all procedures are stored lowercase
  before_save { self.name.downcase! }

  # but when we validate the incoming record we compare case insensitive
  # because we haven't downcased incoming string yet
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def to_s
    name
  end

  def self.names
    self.pluck(:name).sort
  end

  # Search aliases are editorial data, not alternate procedure records. Keep
  # the canonical procedure name unchanged while allowing localized searches.
  def search_aliases
    I18n.available_locales.flat_map do |locale|
      aliases = I18n.t(:procedure_aliases, locale: locale, default: {})
      aliases[name] || aliases[name.to_sym] || []
    end.compact.uniq
  end
end
