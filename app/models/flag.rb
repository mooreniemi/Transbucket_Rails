class Flag
  # attr_accessor :content, :user

  def initialize(user, content)
    @user = user
    @content = content
  end

  def flag_on
    if flagger_is_pin_author?
      content.review!
      return {status: :removed}
    elsif content.votes.down.size >= 2
      content.review!
      return {status: :removed}
    else
      content.downvote_from(user)
      return {status: :voted_down}
    end
  end

  def flagger_is_pin_author?
    return false if content.is_a?(Pin)
    #get id of parent pin of the comment
    pin_author = Pin.find(content.commentable_id).user
    User.find(user) == User.find(pin_author)
  end

end