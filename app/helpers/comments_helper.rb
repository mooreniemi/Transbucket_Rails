module CommentsHelper
  def comments_asc
    timestamp = comment_threads.order('updated_at DESC').first.try(:updated_at)
    return [] if timestamp.nil?

    Rails.cache.fetch("#{timestamp.to_i}-#{comment_threads.pluck(:id).join('-')}") do
      comment_threads.where(parent_id: nil).
        includes(:user).
        order('updated_at asc')
    end
  end
end
