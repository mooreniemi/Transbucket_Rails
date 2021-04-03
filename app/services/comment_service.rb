class CommentService
  attr_reader :body, :commentable, :commenter, :parent_comment_id, :contains_question
  attr_accessor :comment

  def initialize(commentable, commenter, body, parent_comment_id = nil)
    @commentable = commentable
    @body = body
    @contains_question = body.include?("?")
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

    @comment = Comment.build_from(commentable, commenter, body)
    @comment.save!

    notify_author if wants_email

    # threading
    @comment.move_to_child_of(Comment.find(parent_comment_id)) unless parent_comment_id.blank?
  end

  private

  def notify_author
    begin
      send_email_notification
    rescue => e
      puts "#{e} was raised while attempting to send notification " +
           "on #{commentable.class} #{commentable.id} to User #{commentable.user.id}"
    end
  end

  def send_email_notification
    # NOTE: not exactly bleeding edge nlp here but succeeds most of the time
    CommentMailer.new_comment_email(commentable.user.id, commentable.id, contains_question).deliver_now
  end
end
