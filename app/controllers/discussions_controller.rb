class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: :show

  def new
    @discussion = current_user.discussions.new(category: 'discussion', visibility: 'everyone')
  end

  def create
    @discussion = current_user.discussions.new(discussion_params)
    saved = @discussion.save
    SubmissionEventRecorder.record(content: @discussion, user: current_user, event_type: 'discussion_created', locale: I18n.locale) if saved

    # From the feed's form (feed_toolbar.js): the new card to put at the top
    # of the feed, or the form again with what to fix.
    if request.xhr?
      if saved
        item = HomeFeedQuery::Item.new(record: @discussion, kind: 'discussion_post', occurred_at: @discussion.created_at, reply_count: 0)
        render partial: 'pins/feed_item', locals: { item: item, event_context: {} }, status: :created
      else
        render partial: 'discussions/form', locals: { discussion: @discussion, in_feed: true }, status: :unprocessable_entity
      end
    elsif saved
      redirect_to discussion_path(@discussion, locale: I18n.locale), notice: t('public.discussion.created', default: 'Discussion posted')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comments = @discussion.comments_asc(viewer: current_user)
    ActiveRecord::Associations::Preloader.new(records: @comments, associations: { user: :trust_grants }).call
    @new_comment = Comment.build_from(@discussion, current_user, '')
    # The phone feed opens it over the feed (pin_viewer.js) with ?viewer=1.
    render layout: !params[:viewer].present?
  end

  # Its author or a moderator, from its feed card (comments.js.coffee hides
  # the card); anyone else gets not found.
  def destroy
    discussions = current_user.moderator? ? Discussion.all : current_user.discussions
    discussions.find(params[:id]).destroy!
    render json: { status: 'destroyed' }, status: :ok
  end

  private

  def set_discussion
    @discussion = Discussion.published.visible_to(current_user).find(params[:id])
  end

  def discussion_params
    params.require(:discussion).permit(:title, :body, :category, :visibility)
  end
end
