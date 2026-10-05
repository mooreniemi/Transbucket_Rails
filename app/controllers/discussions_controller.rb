class DiscussionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion, only: :show

  def new
    @discussion = current_user.discussions.new(category: 'discussion', visibility: 'everyone')
  end

  def create
    @discussion = current_user.discussions.new(discussion_params)

    # From the feed's form (feed_toolbar.js): the new card to put at the top
    # of the feed, or the form again with what to fix.
    if request.xhr?
      if @discussion.save
        item = HomeFeedQuery::Item.new(record: @discussion, kind: 'discussion_post', occurred_at: @discussion.created_at, reply_count: 0)
        render partial: 'pins/feed_item', locals: { item: item, event_context: {} }, status: :created
      else
        render partial: 'discussions/form', locals: { discussion: @discussion, in_feed: true }, status: :unprocessable_entity
      end
    elsif @discussion.save
      redirect_to discussion_path(@discussion, locale: I18n.locale), notice: t('public.discussion.created', default: 'Discussion posted')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comments = @discussion.comments_asc(viewer: current_user)
    ActiveRecord::Associations::Preloader.new(records: @comments, associations: { user: :trust_grants }).call
    @new_comment = Comment.build_from(@discussion, current_user, '')
  end

  private

  def set_discussion
    @discussion = Discussion.published.visible_to(current_user).find(params[:id])
  end

  def discussion_params
    params.require(:discussion).permit(:title, :body, :category, :visibility)
  end
end
