class Procedure < ActiveRecord::Base
  include Stats
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  validates :name, uniqueness: true
  validates :name, presence: true

  def to_s
    name
  end

  def self.names
    self.pluck(:name).sort
  end

  def comments_desc
    timestamp = comment_threads.order('updated_at DESC').first.try(:updated_at)
    return [] if timestamp.nil?

    Rails.cache.fetch("#{timestamp.to_i}-#{comment_threads.pluck(:id).join('-')}") do
      comment_threads.where(parent_id: nil).
        includes(:user).
        order('created_at desc')
    end
  end
end
