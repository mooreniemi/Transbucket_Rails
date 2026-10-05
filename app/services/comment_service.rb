class CommentService
  attr_reader :body, :commentable, :commenter, :parent_comment_id, :contains_question, :visibility
  attr_accessor :comment

  def initialize(commentable, commenter, body, parent_comment_id = nil, visibility = 'everyone')
    @commentable = commentable
    @body = body
    @contains_question = body.include?("?")
    @commenter = commenter
    @parent_comment_id = parent_comment_id
    @visibility = if %w[Procedure Surgeon Discussion].include?(commentable.class.name)
      visibility.to_s.presence_in(Comment::VISIBILITIES) || 'everyone'
    else
      'everyone'
    end
  end

  def create
    if commentable.try(:user).present? && commentable.user != commenter
      policy = UserPolicy.new(commentable.user)
      wants_email = policy.wants_email?
    else
      wants_email = false
    end

    @comment = Comment.build_from(commentable, commenter, body)
    @comment.visibility = parent_comment_visibility || @visibility
    @comment.save!

    notify_author if wants_email

    # threading
    @comment.move_to_child_of(Comment.find(parent_comment_id)) unless parent_comment_id.blank?
  end

  private

  def parent_comment_visibility
    return if parent_comment_id.blank?

    Comment.find(parent_comment_id).root.visibility
  end

  def notify_author
    begin
      send_email_notification
    rescue => e
      puts "#{e.class} was raised while attempting to send notification " +
           "on #{commentable.class} #{commentable.id} to User #{commentable.user.id}"
    end
  end

  def send_email_notification
    # NOTE: not exactly bleeding edge nlp here but succeeds most of the time
    CommentMailer.new_comment_email(commentable.user.id, commentable.id, contains_question).deliver_now
  end
end
