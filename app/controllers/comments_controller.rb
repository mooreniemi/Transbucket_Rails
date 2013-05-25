# comments_controller.rb
    class CommentsController < ApplicationController

      def create
        @comment_hash = params[:comment]
        @obj = @comment_hash[:commentable_type].constantize.find(@comment_hash[:commentable_id])
        # Not implemented: check to see whether the user has permission to create a comment on this object
        @comment = Comment.build_from(@obj, current_user, @comment_hash[:body])
        if @comment.save
          render :html => "comments/comment", :locals => { :comment => @comment }, :layout => false, :status => :created
        else
          render :js => "alert('error saving comment');"
        end
      end
      def destroy
      @comment = Comment.find(params[:id])
      if @comment.destroy
        render :json => @comment, :status => :ok
      else
        render :js => "alert('error deleting comment');"
      end
    end
    end