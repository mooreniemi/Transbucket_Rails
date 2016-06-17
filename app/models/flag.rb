# Applied to a comment or pin by users.
class Flag
  attr_accessor :content, :user

  def initialize(user, content)
    @user = user
    @content = content
  end

  def flag_on
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

  def flagger_is_pin_author?
    return false if content.is_a?(Pin)
    return false if user.nil?
    pin_author = Pin.find(content.commentable_id).user
    return false if pin_author.nil?
    user.id == pin_author.id
  end
end
