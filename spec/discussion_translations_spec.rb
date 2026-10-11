require 'rails_helper'

# Discussions, the subject pages, the feed toolbar and the header/menu changes
# (config/locales/discussions.yml): every string in every language the site
# offers, so nobody gets English mixed into their page. Counts use each
# language's own plural forms (Russian, Polish and Arabic have several).
describe 'discussion translations' do
  LOCALES = ApplicationController::SUPPORTED_LOCALES

  KEYS = %w[
    directory.by_procedure directory.page_actions directory.stats directory.discussion_about directory.feed_actions
    filter_menu.all_content_short filter_menu.content filter_menu.discussions_short filter_menu.show filter_menu.submissions_short
    header.add_submission header.cancel_search header.start_discussion
    public.comment.audience_contributors public.comment.audience_procedure_contributors public.comment.audience_surgeon_contributors
    public.comment.locked_discussion_for_html public.comment.locked_join public.comment.visibility_everyone public.comment.visibility_label
    public.discussion.body public.discussion.cancel public.discussion.category public.discussion.created public.discussion.new_title
    public.discussion.post public.discussion.title public.discussion.title_placeholder public.discussion.toolbar_label
    public.feed.read_more public.pin.start_discussion public.pin.toolbar_label public.surgeon.website
  ].freeze

  PLURAL_KEYS = %w[public.feed.reply_count public.rating.view_procedure_submissions].freeze

  it 'has every string in every language, without falling back to English' do
    missing = LOCALES.flat_map do |locale|
      (KEYS + PLURAL_KEYS + Discussion::CATEGORIES.map { |category| "public.discussion.categories.#{category}" }).
        reject { |key| I18n.exists?(key, locale.to_sym, fallback: false) }.
        map { |key| "#{locale}: #{key}" }
    end

    expect(missing).to be_empty
  end

  it 'actually translates them (only names like "Filter" may match English)' do
    LOCALES.without('en').each do |locale|
      same = KEYS.select { |key| I18n.t(key, locale: locale, subject: 'X', audience: 'X') == I18n.t(key, locale: :en, subject: 'X', audience: 'X') }
      expect(same.size).to be <= 4, "#{locale} leaves these in English: #{same.join(', ')}"
    end
  end

  it 'keeps the placeholders the code fills in' do
    LOCALES.each do |locale|
      expect(I18n.t('public.comment.audience_procedure_contributors', locale: locale, subject: 'SUBJ')).to include('SUBJ')
      expect(I18n.t('public.comment.audience_surgeon_contributors', locale: locale, subject: 'SUBJ')).to include('SUBJ')
      expect(I18n.t('public.comment.locked_discussion_for_html', locale: locale, audience: 'AUD')).to include('AUD')
    end
  end

  it 'counts in every language without missing a plural form' do
    LOCALES.each do |locale|
      PLURAL_KEYS.each do |key|
        [0, 1, 2, 3, 5, 11, 21, 22, 25, 100, 101].each do |count|
          text = I18n.t(key, locale: locale, count: count, raise: true)
          expect(text).to be_a(String)
          expect(text).not_to be_empty
          # Arabic spells out none, one and two.
          expect(text).to include(count.to_s) unless locale == 'ar' && count <= 2
        end
      end
    end
  end
end
