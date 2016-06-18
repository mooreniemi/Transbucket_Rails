#app/services/comments_service.rb
class CommentService
  attr_reader :body, :commentable, :commenter
  attr_accessor :comment

  def initialize(commentable, commenter, body)
    @commentable = commentable
    @body = body
    @commenter = commenter
  end

  def create
    if commentable.user.present?
      policy = UserPolicy.new(commentable.user)
      wants_email = policy.wants_email?
    else
      wants_email = false
    end

    @comment = wants_email ? create_and_notify : build

    @comment.save
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
