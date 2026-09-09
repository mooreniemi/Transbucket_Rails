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
    @newsfeed_entries = %w(procedure_cleanup prefix_search discord_invite locales).map do |entry|
      { body: I18n.t("newsfeed.entries.#{entry}"), date: I18n.t('newsfeed.date') }
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
end
