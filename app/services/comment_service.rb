class CommentService
  attr_reader :body, :commentable, :commenter, :parent_comment_id
  attr_accessor :comment

  def initialize(commentable, commenter, body, parent_comment_id = nil)
    @commentable = commentable
    @body = body
    @commenter = commenter
    @parent_comment_id = parent_comment_id
  end

  def create
    if commentable.try(:user).present? && commentable.user != commenter
      policy = UserPolicy.new(commentable.user)
      wants_email = policy.wants_email?
    else
      wants_email = false
    end

    @comment = wants_email ? create_and_notify : build
    @comment.save!

    # threading
    @comment.move_to_child_of(Comment.find(parent_comment_id)) unless parent_comment_id.blank?
  end

  private

  def build
    Comment.build_from(commentable, commenter, body)
  end

  # TODO we shouldnt be sending notification until we are
  # sure the save happened without error
  def create_and_notify
    comment = build

    begin
      send_email_notification(comment)
    rescue => e
      puts "#{e} was raised while attempting to send notification " +
           "on #{commentable.class} #{commentable.id} to User #{commentable.user.id}"
    end

    comment
  end

  def send_email_notification(comment)
    CommentMailer.new_comment_email(commentable.user.id, commentable.id).deliver_now
  end
end
