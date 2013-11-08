# comments_controller.rb
class CommentsController < ApplicationController
respond_to :js

  def create
    #binding.pry
    @comment_hash = params[:comment]
    @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
    # Not implemented: check to see whether the user has permission to create a comment on this object

    #@comment = Comment.build_from(@obj, current_user, @comment_hash[:body])
    service = CommentService.new(@obj, current_user, @comment_hash[:body])
    policy = UserPolicy.new(@obj.user)

    if policy.wants_email?
      @comment = service.create_and_notify
    else
      @comment = service.create
    end

    if @comment.save
      render :partial => "comments/comment", :locals => { :comment => @comment }, :layout => false, :status => :created
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.destroy
      render :json => @comment, :status => :ok
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end
end