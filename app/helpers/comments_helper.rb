module CommentsHelper
  # Who a new discussion is for, in plain words (comments/_form).
  def comment_visibility_options(commentable)
    everyone = [t('public.comment.visibility_everyone', default: 'Everyone'), 'everyone']
    if commentable.class.name == 'Discussion'
      return [
        everyone,
        [t('public.comment.audience_contributors', default: 'People who have posted a submission'), 'contributors']
      ]
    end
    return [everyone] unless %w[Procedure Surgeon].include?(commentable.class.name)

    [
      everyone,
      [t('public.comment.audience_contributors', default: 'People who have posted a submission'), 'contributors'],
      [t('public.comment.audience_subject_contributors', subject: commentable.to_s, default: 'People who posted about %{subject}'), 'subject_contributors']
    ]
  end

  def comments_asc(viewer: nil)
    visible = Comment.visible_to(viewer).where(commentable_type: self.class.name, commentable_id: id)
    return visible.where(parent_id: nil).includes(:user).order('updated_at asc') if viewer.present?

    timestamp = visible.order('updated_at DESC').first.try(:updated_at)
    return [] if timestamp.nil?

    Rails.cache.fetch("#{timestamp.to_i}-#{visible.pluck(:id).join('-')}") do
      visible.where(parent_id: nil).
        includes(:user).
        order('updated_at asc')
    end
  end
end
