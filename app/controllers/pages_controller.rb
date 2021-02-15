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
    @rss = SimpleRSS.parse open('https://transbucket.tumblr.com/rss#_=_').read
    @coder = HTMLEntities.new
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
