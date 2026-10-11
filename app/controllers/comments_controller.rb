class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_destroy, only: :destroy

  # Comments are only ever polymorphically attached to these two types (see
  # app/views/pins/show.html.erb and app/views/procedures/show.html.erb).
  # commentable_type otherwise comes straight from user-controlled params, so
  # constantize-ing it unchecked would let a request target arbitrary AR models.
  ALLOWED_COMMENTABLE_TYPES = %w[Pin Procedure Surgeon Discussion].freeze

  class InvalidCommentableType < StandardError; end
  rescue_from InvalidCommentableType, with: :render_invalid_commentable_type

  # One discussion on its own page: the post, its replies and Reply. The phone
  # feed opens it over the feed (pin_viewer.js) with ?viewer=1, which leaves
  # the layout out, as pin pages do. A reply goes to its discussion, at the
  # reply; a comment on a submission goes to the submission page.
  def show
    comment = Comment.find(params[:id])
    raise ActiveRecord::RecordNotFound unless comment.published? && Comment.visible_to(current_user).where(id: comment.id).exists? || current_user.admin?

    root = comment.root
    anchor = "comment-#{comment.id}"
    if root.commentable_type == 'Pin'
      redirect_to pin_path(root.commentable, anchor: anchor)
    elsif root != comment
      redirect_to comment_path(root, **params.permit(:viewer, :reply_to).to_h.symbolize_keys, anchor: anchor)
    elsif root.commentable_type == 'Discussion'
      redirect_to discussion_path(root.commentable, anchor: anchor)
    else
      @comment = root
      @subject = root.commentable
      render layout: !params[:viewer].present?
    end
  end

  def new
    @commentable = commentable
    @parent_id = parent_id # as in, parent comment, may be nil
    @new_comment = Comment.build_from(@commentable, current_user, "")
  end

  def create
    subject = commented_on
    ensure_can_reply!(subject)
    service = CommentService.new(
      subject,
      current_user,
      comment_params[:body],
      parent_id,
      comment_params[:visibility]
    )
    service.create

    @comment = service.comment
    SubmissionEventRecorder.record(content: @comment, user: current_user, event_type: 'comment_created', locale: I18n.locale) if @comment.persisted? && @comment.errors.empty?
    #TODO clean this up
    case @comment.commentable_type
    when "Pin"
      @pin = @comment.commentable_type.constantize.find(@comment.commentable_id)
    when "Procedure"
      @procedure = @comment.commentable_type.constantize.find(@comment.commentable_id)
    when "Surgeon"
      @surgeon = @comment.commentable_type.constantize.find(@comment.commentable_id)
    when "Discussion"
      @discussion = @comment.commentable_type.constantize.find(@comment.commentable_id)
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
      render :json => {'status': 'destroyed'}, :status => :ok
    else
      render :json => @comment.errors, :status => :unprocessable_entity
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:commentable_id, :commentable_type, :parent_id, :body, :visibility)
  end

  def commentable
    commentable_class(params[:commentable_type]).find(params[:commentable_id])
  end

  def parent_id
    begin
      comment_params[:parent_id]
    rescue
      params[:parent_id]
    end
  end

  # Only people who can read a discussion can reply to it, and only under a
  # comment in the same place that they can read; otherwise it's not found.
  def ensure_can_reply!(subject)
    Discussion.published.visible_to(current_user).find(subject.id) if subject.is_a?(Discussion)
    return if parent_id.blank?

    Comment.visible_to(current_user).where(commentable: subject).find(parent_id)
  end

  def commented_on
    commentable_class(comment_params[:commentable_type]).find(comment_params[:commentable_id])
  end

  def commentable_class(type)
    raise InvalidCommentableType unless ALLOWED_COMMENTABLE_TYPES.include?(type)
    type.constantize
  end

  def render_invalid_commentable_type
    render json: { error: "invalid commentable_type" }, status: :bad_request
  end

  def authorize_destroy
    comment = Comment.find(params[:id])
    head :forbidden unless comment.user_id == current_user.id || current_user.moderator?
  end
end
