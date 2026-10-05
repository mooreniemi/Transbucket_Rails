module DiscussionsHelper
  # "Discussion (3)" near the top of a procedure or surgeon page, jumping to
  # the discussion at the bottom (these pages get long on a phone). Counts
  # published comments, replies included; no count when there are none yet.
  # Render it outside any fragment cache so the count stays current.
  def discussion_jump_link(subject)
    count = Comment.published_counts_for(subject.class.name, [subject.id])[subject.id].to_i
    label = t('public.pin.discussion')
    label = "#{label} (#{count})" if count.positive?
    link_to '#discussion', class: 'discussion-jump' do
      safe_join([fa_icon('comments-o'), ' ', label])
    end
  end
end
