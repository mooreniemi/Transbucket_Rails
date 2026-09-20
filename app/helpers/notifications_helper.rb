# NOTE: this depends on delayed_jobs
module NotificationsHelper
  extend ActiveSupport::Concern

  class_methods do
    # Delayed Job serializes the receiver and arguments. Keep moderation email
    # jobs portable across Rails/Ruby upgrades by storing only primitives.
    def admin_review_async(reviewable_type, reviewable_id)
      reviewable_class = {
        'Pin' => Pin,
        'Comment' => Comment
      }.fetch(reviewable_type)
      reviewable = reviewable_class.find_by(id: reviewable_id)
      return unless reviewable

      ReviewMailer.please_review(reviewable).deliver_now
    end
    handle_asynchronously :admin_review_async
  end

  def admin_review
    self.class.admin_review_async(self.class.name, id)
  end
end
