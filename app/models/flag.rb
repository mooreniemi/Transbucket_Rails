# Applied to a comment or pin by users.
class Flag
  attr_accessor :content, :user

  def initialize(user, content)
    @user = user
    @content = content
  end

  def flag_on
    ModerationEventRecorder.record(action: :flag, user: user, content: content)

    if flagger_is_pin_author?
      content.review!
      return { status: :removed }
    elsif content.votes.down.size >= 2
      content.review!
      return { status: :removed }
    else
      content.downvote_from(user)
      return { status: :voted_down }
    end
  end

  private

  # A pin's author can take a comment on their own pin straight to review.
  # Comments on procedures and surgeons have no such owner.
  def flagger_is_pin_author?
    return false if content.is_a?(Pin)
    return false if user.nil?
    return false unless content.commentable_type == 'Pin'
    pin_author = content.commentable&.user
    return false if pin_author.nil?
    user.id == pin_author.id
  end
end
