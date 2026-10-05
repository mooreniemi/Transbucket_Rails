# https://github.com/elight/acts_as_commentable_with_threading/blob/a579b92b497cbb2b5b5e8be78b760cf1c652dfa3/lib/generators/acts_as_commentable_upgrade_migration/comment.rb
class Comment < ActiveRecord::Base
  VISIBILITIES = %w[everyone contributors subject_contributors].freeze

  include AASM
  include NotificationsHelper
  validates :body, presence: true
  validates :user, presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }

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

  # {commentable_id => number of visible comments and replies}, for showing counts
  # on a page of cards in one query. Matches what the thread shows: AASM treats a
  # blank state as the initial (published) one, so those rows count too.
  def self.published_counts_for(commentable_type, commentable_ids)
    return {} if commentable_ids.blank?

    where(commentable_type: commentable_type, commentable_id: commentable_ids)
      .where("comments.state IS NULL OR comments.state IN ('', 'published')")
      .group(:commentable_id).count
  end

  # Visibility is inherited from the root discussion so a private thread never
  # leaks through one of its replies. The correlated EXISTS checks keep this a
  # single SQL query for a page/feed rather than one trust lookup per comment.
  def self.visible_to(user)
    return where(visibility: 'everyone') if user.blank?
    return all if user.respond_to?(:admin?) && user.admin?

    contributor = sanitize_sql_array([
      "EXISTS (SELECT 1 FROM user_trust_grants grants WHERE grants.user_id = ? AND grants.revoked_at IS NULL AND grants.kind IN (?, ?, ?))",
      user.id, 'contributor', 'vetted', 'moderator'
    ])
    subject_contributor = sanitize_sql_array([
      <<~SQL.squish,
        EXISTS (SELECT 1 FROM pins subject_pins
          WHERE subject_pins.user_id = ? AND subject_pins.state = 'published'
            AND ((visibility_roots.commentable_type = 'Procedure' AND subject_pins.procedure_id = visibility_roots.commentable_id)
              OR (visibility_roots.commentable_type = 'Surgeon' AND subject_pins.surgeon_id = visibility_roots.commentable_id)))
      SQL
      user.id
    ])

    joins(<<~SQL.squish).
      LEFT JOIN comments visibility_roots
        ON visibility_roots.commentable_type = comments.commentable_type
       AND visibility_roots.commentable_id = comments.commentable_id
       AND visibility_roots.parent_id IS NULL
       AND visibility_roots.lft <= comments.lft
       AND visibility_roots.rgt >= comments.rgt
    SQL
      where("COALESCE(visibility_roots.visibility, comments.visibility) = 'everyone' OR (COALESCE(visibility_roots.visibility, comments.visibility) = 'contributors' AND (#{contributor})) OR (COALESCE(visibility_roots.visibility, comments.visibility) = 'subject_contributors' AND (#{subject_contributor}))").
      distinct
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
