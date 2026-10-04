class HomeFeedQuery
  Item = Struct.new(:record, :kind, :occurred_at, keyword_init: true)

  PER_PAGE = 30
  attr_reader :page, :per_page

  def initialize(content: 'all', page: 1, per_page: Pin.per_page)
    @content = content.to_s.presence_in(%w[all submissions discussions]) || 'all'
    @page = [page.to_i, 1].max
    @per_page = per_page.to_i.positive? ? per_page.to_i : PER_PAGE
  end

  def call
    items = []
    limit = @page * @per_page
    items.concat(submission_items(limit)) unless @content == 'discussions'
    items.concat(discussion_items(limit)) unless @content == 'submissions'

    items.sort_by { |item| [-item.occurred_at.to_f, -item.record.id] }.
      slice((@page - 1) * @per_page, @per_page) || []
  end

  def total_entries
    submissions = @content == 'discussions' ? 0 : Pin.published.count
    discussions = @content == 'submissions' ? 0 : contextual_comment_scope.count
    submissions + discussions
  end

  private

  def submission_items(limit)
    Pin.published.recent.
      includes(*PinPresenter::CARD_INCLUDES).
      limit(limit).
      map { |pin| Item.new(record: pin, kind: 'submission', occurred_at: pin.updated_at || pin.created_at) }
  end

  def discussion_items(limit)
    contextual_comment_scope.
      includes(:user, :commentable).
      order(created_at: :desc, id: :desc).
      limit(limit).
      map { |comment| Item.new(record: comment, kind: 'discussion', occurred_at: comment.created_at) }
  end

  def contextual_comment_scope
    Comment.where(commentable_type: %w[Procedure Surgeon], parent_id: nil).
      where("comments.state IS NULL OR comments.state IN ('', 'published')")
  end
end
