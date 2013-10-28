class SearchController < ApplicationController
respond_to :json

  def search_terms
    @terms = (Pin.all.map(&:procedure).compact.reject(&:blank?) + Pin.all.map(&:surgeon).compact.reject(&:blank?)).uniq
    @terms.each {|term| term.gsub!(/[\W]/, ' ')}
    render :json => {suggestions: @terms}
  end
end
