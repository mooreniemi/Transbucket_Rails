class Comment < ActiveRecord::Base
  validates :body, :presence => true
  validates :user, :presence => true

  acts_as_votable

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  def has_children?
    self.children.any?
  end

  def flags
    self.votes
  end

  # TODO mixing scopes and class level methods
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def self.build_from(obj, user_id, comment)
    new \
      :commentable => obj,
      :body        => comment,
      :user_id     => user_id.id
  end

  state_machine initial: :published do
    state :pending, value: "pending"
    state :published, value: "published"

    event :publish do
      transition nil => :published
      transition :pending => :published
    end

    event :review do
      transition :published => :pending
    end
  end

end
