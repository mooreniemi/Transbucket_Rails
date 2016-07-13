class CommentsController < ApplicationController
  respond_to :js

  def new
    @commentable = commentable
    @parent_id = parent_id # as in, parent comment, may be nil
    @new_comment = Comment.build_from(@commentable, current_user, "")
  end

  def create
    service = CommentService.new(
      commented_on,
      current_user,
      comment_params[:body],
      parent_id
    )
    service.create

    @comment = service.comment
    #TODO clean this up
    if @comment.commentable_type == "Pin"
      @pin = @comment.commentable_type.constantize.find(@comment.commentable_id)
    else
      @procedure = @comment.commentable_type.constantize.find(@comment.commentable_id)
    end

    if @comment.errors.present?
      render :json => @comment.errors, :status => :unprocessable_entity
    else
      render :partial => "comments/comment", :locals => { :comment => @comment }, :layout => false, :status => :created
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.destroy
      render :nothing => true, :status => :ok
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:commentable_id, :commentable_type, :parent_id, :body)
  end

  def commentable
    params[:commentable_type].constantize.find(params[:commentable_id])
  end

  def parent_id
    begin
      comment_params[:parent_id]
    rescue
      params[:parent_id]
    end
  end

  def commented_on
    comment_params[:commentable_type].constantize.find(comment_params[:commentable_id])
  end
end
