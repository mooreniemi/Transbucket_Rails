module DiscussionsHelper
  # Languages whose audience labels start with a common word ("People who…",
  # "Personas que…") that reads lowercase mid-sentence. Not German (nouns are
  # capitalized), not languages where the label starts with the procedure or
  # surgeon's name, and not ones whose sentence puts it after a colon.
  MID_SENTENCE_LOWERCASE_LOCALES = %w[en es fr it pt-BR nl sv vi].freeze

  # An audience label ("People who posted a submission for X") for use inside
  # a sentence ("A discussion for people who posted...").
  def audience_mid_sentence(label)
    return label unless MID_SENTENCE_LOWERCASE_LOCALES.include?(I18n.locale.to_s)

    label.sub(/\A\p{Lu}/) { |letter| letter.downcase }
  end

  DISCUSSION_CATEGORY_LABELS = {
    'discussion' => 'Discussion',
    'question' => 'Question',
    'experience' => 'Experience',
    'recovery' => 'Recovery',
    'planning' => 'Planning',
    'resources' => 'Resources',
    'community' => 'Community'
  }.freeze

  def discussion_category_options
    Discussion::CATEGORIES.map do |category|
      [t("public.discussion.categories.#{category}", default: DISCUSSION_CATEGORY_LABELS.fetch(category)), category]
    end
  end

  def discussion_category_label(category)
    t("public.discussion.categories.#{category}", default: DISCUSSION_CATEGORY_LABELS.fetch(category, category.humanize))
  end

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
