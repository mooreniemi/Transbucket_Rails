# comments_controller.rb
class CommentsController < ApplicationController
	respond_to :js

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
			render :json => @comment, :status => :ok
		else
			render :json => @comment.errors, :status => :unprocessable_entity
		end
	end

	private
	def comment_hash
		params[:comment]
	end

	def commented_on
		comment_hash[:commentable_type].constantize.find(comment_hash[:commentable_id])
	end
end
