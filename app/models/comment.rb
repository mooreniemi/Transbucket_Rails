# https://github.com/elight/acts_as_commentable_with_threading/blob/a579b92b497cbb2b5b5e8be78b760cf1c652dfa3/lib/generators/acts_as_commentable_upgrade_migration/comment.rb
class Comment < ActiveRecord::Base
  include AASM
  include NotificationsHelper
  validates :body, presence: true
  validates :user, presence: true

  # votes on comments are just flags
  # flags determine whether something needs to be reviewed
  acts_as_votable
  alias_method :flags, :votes

  # this is what turns on threading, otherwise we'd be stuck with
  # recursive eager loading
  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  aasm column: :state do
    state :pending, value: 'pending'
    state :published, value: 'published', initial: :published

    event :publish do
      transitions from: :pending, to: :published
    end

    event :review, :after => :admin_review do
      transitions from: :published, to: :pending
    end
  end

  def self.new_as_of(last_login_time)
    where("created_at > ? and state = 'published'", last_login_time)
  end

  def self.find_comments_by_user(user)
    where(user_id: user.id).order('created_at DESC')
  end

  def self.find_comments_for_commentable(commentable_str, commentable_id)
    where(commentable_type: commentable_str.to_s,
          commentable_id: commentable_id).
          order('created_at DESC')
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

  def snippet
    if body.include?(' ')
      body.split(' ').first(5).join(' ')
    else
      body[0..49]
    end
  end

  # helper method to check if a comment has children
  def has_children?
    children.size > 0
  end
end
