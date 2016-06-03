# Comments are applied on submissions, no threading on each other currently.
# Much of this class was generated from commentable gem.
class Comment < ActiveRecord::Base
  include AASM
  validates :body, presence: true
  validates :user, presence: true

  acts_as_votable

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  aasm column: :state do
    state :pending, value: 'pending'
    state :published, value: 'published', initial: :published

    event :publish do
      transitions from: :pending, to: :published
    end

    event :review do
      transitions from: :published, to: :pending
    end
  end

  def flags
    votes
  end

  def snippet
    last.body.split(' ').first(50).join(' ')
  end

  def self.find_comments_by_user(user)
    where(user_id: user.id).order('created_at DESC')
  end

  def self.find_comments_for_commentable(commentable_str, commentable_id)
    where(commentable_type: commentable_str.to_s,
          commentable_id: commentable_id).
          order('created_at DESC')
  end

  def self.new_comments_to(user)
    where('created_at > ? and state = ?', user, 'published')
  end

  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def self.build_from(obj, user_id, comment)
    new \
      commentable: obj,
      body: comment,
      user_id: user_id.id
  end
end
