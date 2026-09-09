require 'spec_helper'
require 'yaml'

describe 'application locales' do
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar).freeze
  REQUIRED_KEYS = %w(site.description homepage.title homepage.intro header.search footer.discord_prefix locale.label newsfeed.title newsfeed.description newsfeed.date newsfeed.entries.procedure_cleanup newsfeed.entries.prefix_search newsfeed.entries.discord_invite newsfeed.entries.locales).freeze

  it 'defines the first-pass public UI keys for every supported locale' do
    SUPPORTED_LOCALES.each do |locale|
      REQUIRED_KEYS.each do |key|
        expect(I18n.t(key, locale: locale)).not_to start_with('translation missing')
      end
    end
  end
end
