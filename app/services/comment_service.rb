#app/services/comments_service.rb
class CommentService
  attr_reader :body, :commentable, :user

  def initialize(commentable, user, body)
    @commentable = commentable
    @body = body
    @user = user
  end

  def create
    comment = Comment.build_from(commentable, user, body)
    comment
  end

  def create_and_notify
    comment = create
    send_email_notification(comment)
    comment
  end

  def send_email_notification(comment)
    CommentMailer.new_comment_email(self).deliver
  end

end