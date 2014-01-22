class Flag

  def initialize(user, content)
    @user = user
    @content = content
  end

  def flag_on
    if @content.votes.down.size >= 2 #&& @content.published?
      @content.review!
      return {status: :removed}
    else
      @content.downvote_from(@user)
      return {status: :voted_down}
    end
  end

end