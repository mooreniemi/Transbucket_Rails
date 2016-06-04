#app/services/comments_service.rb
class CommentService
  attr_reader :body, :commentable, :user
  attr_accessor :comment

  def initialize(commentable, user, body)
    @commentable = commentable
    @body = body
    @user = user
  end

  def create
    policy = UserPolicy.new(user)

    if policy.wants_email?
      @comment = create_and_notify
    else
      @comment = build
    end

    @comment.save
  end

  private

  def build
    Comment.build_from(commentable, user, body)
  end

  def create_and_notify
    comment = build

    begin
      send_email_notification(comment)
    rescue => e
      puts "#{e} was raised while attempting to send notification " +
        "on #{commentable.class} #{commentable.id} to User #{user.id}"
    end

    comment
  end

  def send_email_notification(comment)
    CommentMailer.new_comment_email(user.id, commentable.id).deliver_now
  end
end
