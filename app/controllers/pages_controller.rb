class PagesController < ApplicationController
  caches_page :home, :about, :terms, :privacy, :bookmarks
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
    @newsfeed_entries = [
      {
        body: "Procedure search now matches prefixes, so typing the start of a name like phallo or orchi gets you to the right results faster.",
        date: "September 2026"
      },
      {
        body: "The Discord community invite now points to a permanent link.",
        date: "September 2026"
      }
    ]
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
