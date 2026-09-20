class PagesController < ApplicationController
  NEWSFEED_ENTRY_TIMESTAMPS = {
    'pronouns' => Time.utc(2026, 9, 20, 22, 30),
    'comment_counts' => Time.utc(2026, 9, 20, 22, 20),
    'safe_mode_blur' => Time.utc(2026, 9, 20, 22, 10),
    'mobile_refresh' => Time.utc(2026, 9, 20, 22, 0),
    'contributor_badges' => Time.utc(2026, 9, 20, 21, 15),
    'readable_pin_details' => Time.utc(2026, 9, 20, 3, 45),
    'mobile_directory_layout' => Time.utc(2026, 9, 19, 22, 40),
    'automatic_photo_resizing' => Time.utc(2026, 9, 19, 22, 30),
    'recent_for_you' => Time.utc(2026, 9, 19, 20, 46),
    'complication_cleanup' => Time.utc(2026, 9, 19, 20, 20),
    'comparison_stats' => Time.utc(2026, 9, 18, 23, 0),
    'directory_improvements' => Time.utc(2026, 9, 13, 21, 0),
    'locales' => Time.utc(2026, 9, 10, 23, 0),
    'discord_invite' => Time.utc(2026, 9, 6, 22, 0),
    'prefix_search' => Time.utc(2026, 9, 6, 20, 30),
    'procedure_cleanup' => Time.utc(2026, 9, 6, 20, 0)
  }.freeze

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
    @newsfeed_entries = NEWSFEED_ENTRY_TIMESTAMPS.sort_by { |_entry, timestamp| -timestamp.to_i }.map do |entry, published_at|
      links = newsfeed_links_for(entry)
      body_key = "newsfeed.entries.#{entry}"
      body = I18n.t(body_key, default: I18n.t(body_key, locale: :en)) unless entry == 'comparison_stats'
      entry_data = {
        body: body,
        body_key: (body_key if %w[comparison_stats recent_for_you].include?(entry)),
        date: I18n.l(published_at.in_time_zone, format: :long),
        published_at: published_at,
        links: links
      }
      if entry == 'comparison_stats'
        entry_data[:images] = %w(procedure-comparison-demo surgeon-comparison-demo).map { |image| "newsfeed/#{image}.png" }
      elsif entry == 'complication_cleanup'
        entry_data[:images] = ['newsfeed/complication-tags-demo.jpg']
        entry_data[:image_alt] = I18n.t('newsfeed.complication_image_alt', default: 'Complication tag editor using short tags and suggestions')
      elsif entry == 'recent_for_you'
        entry_data[:images] = ['newsfeed/recent-for-you-demo.jpg']
        entry_data[:image_alt] = I18n.t('newsfeed.recent_for_you_image_alt', default: 'Recent and For You submission feeds using fictional demo data')
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
    when 'recent_for_you'
      [[t('newsfeed.links.recent_submissions', default: 'Recent submissions'), pins_path(feed: 'recent', locale: I18n.locale)],
       [t('newsfeed.links.for_you', default: 'For You'), pins_path(feed: 'for_you', locale: I18n.locale)]]
    when 'automatic_photo_resizing'
      [[t('newsfeed.links.submit_photo', default: 'Submit a photo'), new_pin_path(locale: I18n.locale)]]
    when 'mobile_refresh', 'comment_counts'
      [[t('newsfeed.links.browse_submissions', default: 'Browse submissions'), pins_path(locale: I18n.locale)]]
    when 'contributor_badges'
      [[t('newsfeed.links.browse_submissions', default: 'Browse submissions'), pins_path(locale: I18n.locale)]]
    when 'directory_improvements'
      [[t('newsfeed.links.browse_procedures', default: 'Browse procedures'), procedures_path(locale: I18n.locale)],
       [t('newsfeed.links.browse_surgeons', default: 'browse surgeons'), surgeons_path(locale: I18n.locale)]]
    when 'mobile_directory_layout'
      [[t('newsfeed.links.browse_surgeons', default: 'Browse surgeons'), surgeons_path(locale: I18n.locale)]]
    when 'readable_pin_details'
      [[t('newsfeed.links.browse_submissions', default: 'Browse submissions'), pins_path(locale: I18n.locale)]]
    when 'locales' then [[t('newsfeed.links.choose_language', default: 'Choose a language'), home_path(locale: I18n.locale)]]
    when 'discord_invite' then [[t('newsfeed.links.join_discord', default: 'Join Discord'), 'https://discord.gg/fRW4RnPqgv']]
    when 'prefix_search' then [[t('newsfeed.links.search_pins', default: 'Search pins'), pins_path(locale: I18n.locale)]]
    when 'procedure_cleanup' then [[t('newsfeed.links.browse_procedures', default: 'Browse procedures'), procedures_path(locale: I18n.locale)]]
    else []
    end
  end
end
