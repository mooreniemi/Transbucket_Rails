class PagesController < ApplicationController
  # Page-cache keys use the full request path, so each locale gets its own cached document.
  caches_page :home, :about, :terms, :privacy
  before_filter :force_request_format_to_html

  def home
  end

  def about
  end

  def terms
  end

  def privacy
  end

  def newsfeed
    @newsfeed_entries = %w(comparison_stats directory_improvements locales discord_invite prefix_search procedure_cleanup).map do |entry|
      entry_data = { body: I18n.t("newsfeed.entries.#{entry}", default: I18n.t("newsfeed.entries.#{entry}", locale: :en)), date: I18n.t('newsfeed.date') }
      if entry == 'comparison_stats'
        entry_data[:images] = %w(procedure-comparison-demo surgeon-comparison-demo).map { |image| "newsfeed/#{image}.png" }
      end
      entry_data[:link] = newsfeed_link_for(entry)
      entry_data
    end
  end

  def bookmarks
    respond_to do |format|
      format.html { render 'pages/bookmarks' }
    end
  end

  private

  def force_request_format_to_html
    request.format = :html
  end

  def newsfeed_link_for(entry)
    case entry
    when 'comparison_stats' then compare_procedures_path(locale: I18n.locale)
    when 'directory_improvements', 'procedure_cleanup' then procedures_path(locale: I18n.locale)
    when 'locales' then home_path(locale: I18n.locale)
    when 'prefix_search' then pins_path(locale: I18n.locale)
    when 'discord_invite' then 'https://discord.gg/fRW4RnPqgv'
    end
  end
end
