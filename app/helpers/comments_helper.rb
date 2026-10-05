module CommentsHelper
  def comment_visibility_options(commentable)
    return [[t('public.comment.visibility_everyone', default: 'Everyone'), 'everyone']] unless %w[Procedure Surgeon].include?(commentable.class.name)

    [
      [t('public.comment.visibility_everyone', default: 'Everyone'), 'everyone'],
      [t('public.comment.visibility_contributors', default: 'Contributors'), 'contributors'],
      [t('public.comment.visibility_subject_contributors', default: 'Subject contributors'), 'subject_contributors']
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
