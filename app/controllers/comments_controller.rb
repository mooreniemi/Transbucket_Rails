class CommentsController < ApplicationController
  respond_to :js

  def new
    @commentable = commentable_type.constantize.find(parent_id)
    @new_comment = Comment.build_from(@commentable, current_user, "")
  end

  def create
    service = CommentService.new(commented_on, current_user, comment_hash[:body])
    service.create
    @comment = service.comment

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
  def parent_id
    params[:parent_id]
  end

  def commentable_type
    params.fetch(:commentable_type, "Comment")
  end

  def comment_hash
    params[:comment]
  end

  def commented_on
    comment_hash[:commentable_type].constantize.find(comment_hash[:commentable_id])
  end
end
