class PagesController < ApplicationController
  # Page-cache keys use the full request path, so each locale gets its own cached document.
  caches_page :home, :about, :terms, :privacy
  before_filter :force_request_format_to_html
  before_filter :authenticate_user!, only: :compare

  def home
  end

  def about
  end

  def terms
  end

  def privacy
  end

  def compare
    @comparison_type = %w(procedures surgeons).include?(params[:type]) ? params[:type] : 'procedures'
    @comparison_options = if @comparison_type == 'surgeons'
      Surgeon.order(:last_name, :first_name)
    else
      Procedure.order(:name)
    end
  end

  def newsfeed
    @newsfeed_entries = %w(comparison_stats complication_cleanup directory_improvements locales discord_invite prefix_search procedure_cleanup).map do |entry|
      links = newsfeed_links_for(entry)
      body_key = "newsfeed.entries.#{entry}"
      body = I18n.t(body_key, default: I18n.t(body_key, locale: :en)) unless entry == 'comparison_stats'
      entry_data = { body: body, body_key: (body_key if entry == 'comparison_stats'), date: I18n.t('newsfeed.date'), links: links }
      if entry == 'comparison_stats'
        entry_data[:images] = %w(procedure-comparison-demo surgeon-comparison-demo).map { |image| "newsfeed/#{image}.png" }
      elsif entry == 'complication_cleanup'
        entry_data[:images] = ['newsfeed/complication-tags-demo.jpg']
        entry_data[:image_alt] = I18n.t('newsfeed.complication_image_alt', default: 'Complication tag editor using short tags and suggestions')
      end
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

  def newsfeed_links_for(entry)
    case entry
    when 'comparison_stats'
      [[t('newsfeed.links.compare_procedures', default: 'Compare procedures'), compare_procedures_path(locale: I18n.locale)],
       [t('newsfeed.links.compare_surgeons', default: 'compare surgeons'), compare_surgeons_path(locale: I18n.locale)]]
    when 'directory_improvements'
      [[t('newsfeed.links.browse_procedures', default: 'Browse procedures'), procedures_path(locale: I18n.locale)],
       [t('newsfeed.links.browse_surgeons', default: 'browse surgeons'), surgeons_path(locale: I18n.locale)]]
    when 'locales' then [[t('newsfeed.links.choose_language', default: 'Choose a language'), home_path(locale: I18n.locale)]]
    when 'discord_invite' then [[t('newsfeed.links.join_discord', default: 'Join Discord'), 'https://discord.gg/fRW4RnPqgv']]
    when 'prefix_search' then [[t('newsfeed.links.search_pins', default: 'Search pins'), pins_path(locale: I18n.locale)]]
    when 'procedure_cleanup' then [[t('newsfeed.links.browse_procedures', default: 'Browse procedures'), procedures_path(locale: I18n.locale)]]
    else []
    end
  end
end
