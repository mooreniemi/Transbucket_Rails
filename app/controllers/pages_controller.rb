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
        body: "Newsfeed restarted. New updates will start from here.",
        date: "September 7, 2026"
      },
      {
        body: "Older Tumblr posts were condensed into a short archive.",
        date: "August 2026"
      },
      {
        body: "Site maintenance and staging notes were trimmed down.",
        date: "August 2026"
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
