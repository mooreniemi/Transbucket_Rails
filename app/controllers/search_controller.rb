class SearchController < ApplicationController
respond_to :json

  def search_terms
    @terms = (Pin.all.map(&:procedure).compact.reject(&:blank?) + Pin.all.map(&:surgeon).compact.reject(&:blank?)).uniq
    @terms.each {|term| term.gsub!(/[\W]/, ' ')}
    @matches = []
    @term = params[:term]
    @terms.each {|t| @matches << t if /(#{@term})/.match(t.downcase)}
    render :json => @matches
  end

  def surgeons_only
    @terms = (Pin.all.map(&:surgeon).compact.reject(&:blank?)).uniq
    @terms.each {|term| term.gsub!(/[\W]/, ' ')}
    @matches = []
    @term = params[:term]
    @terms.each {|t| @matches << t if /(#{@term})/.match(t.downcase)}
    render :json => @matches
  end
end
