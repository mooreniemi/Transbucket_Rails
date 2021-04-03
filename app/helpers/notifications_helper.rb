# NOTE: this depends on delayed_jobs
module NotificationsHelper
  def admin_review
    ReviewMailer.please_review(self)
  end
  handle_asynchronously :admin_review
end
