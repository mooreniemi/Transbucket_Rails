class ReviewMailer < ApplicationMailer
  default :to => "admin@transbucket.com"

  def please_review(reviewable)
    @reviewable = reviewable
    mail(subject: "TB Admin: Please Review #{reviewable.id}")
  end
end
