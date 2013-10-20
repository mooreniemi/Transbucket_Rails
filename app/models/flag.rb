class Flag

  def initialize(user, content)
    @user = user
    @content = content
  end

  def flag_on
    if @content.votes.down.size >= 2 && @content.published?
      @content.review!
      return {status: :removed}
    else
      return {status: :voted_down} if @content.downvote_from(@user)
    end
  end

end