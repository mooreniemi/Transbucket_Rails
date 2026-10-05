class HomeFeedQuery
  Item = Struct.new(:record, :kind, :occurred_at, :reply_count, keyword_init: true)

  PER_PAGE = 30
  PUBLISHED_COMMENT_SQL = "comments.state IS NULL OR comments.state IN ('', 'published')".freeze
  attr_reader :page, :per_page

  def initialize(content: 'all', page: 1, per_page: Pin.per_page)
    @content = content.to_s.presence_in(%w[all submissions discussions]) || 'all'
    @page = [page.to_i, 1].max
    @per_page = per_page.to_i.positive? ? per_page.to_i : PER_PAGE
  end

  # Both lists are fetched newest-first and merged by the same timestamp each
  # was ordered by in SQL, so taking the top page*per_page of each and slicing
  # gives every item exactly once across pages.
  def call
    items = []
    limit = @page * @per_page
    items.concat(submission_items(limit)) unless @content == 'discussions'
    items.concat(discussion_items(limit)) unless @content == 'submissions'

    page_items = items.sort_by { |item| [-item.occurred_at.to_f, -item.record.id] }.
      slice((@page - 1) * @per_page, @per_page) || []
    add_reply_counts(page_items)
  end

  def total_entries
    submissions = @content == 'discussions' ? 0 : Pin.published.count
    discussions = @content == 'submissions' ? 0 : contextual_comment_scope.count
    submissions + discussions
  end

  private

  # Ordered exactly like the existing feed (Pin.recent): by latest photo
  # activity, not updated_at.
  def submission_items(limit)
    Pin.recent.
      select("pins.*, #{Pin::RECENT_ACTIVITY_SQL} AS feed_activity_at").
      includes(*PinPresenter::CARD_INCLUDES).
      limit(limit).
      map { |pin| Item.new(record: pin, kind: 'submission', occurred_at: pin.feed_activity_at) }
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
      where(PUBLISHED_COMMENT_SQL)
  end

  # Published replies at any depth for the discussions on this page, in one
  # query. Comments nest as a nested set per commentable (lft/rgt).
  def add_reply_counts(items)
    discussion_ids = items.select { |item| item.kind == 'discussion' }.map { |item| item.record.id }
    counts = if discussion_ids.empty?
               {}
             else
               Comment.from('comments parents').
                 joins(<<~SQL.squish).
                   INNER JOIN comments ON comments.commentable_type = parents.commentable_type
                     AND comments.commentable_id = parents.commentable_id
                     AND comments.lft > parents.lft AND comments.rgt < parents.rgt
                 SQL
                 where('parents.id IN (?)', discussion_ids).
                 where(PUBLISHED_COMMENT_SQL).
                 group('parents.id').
                 count
             end
    items.each { |item| item.reply_count = counts.fetch(item.record.id, 0) if item.kind == 'discussion' }
  end
end
