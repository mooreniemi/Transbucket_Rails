class SearchController < ApplicationController
respond_to :json

  # TODO clean this up
  
  def search_terms
    @terms = Procedure.pluck(:name) + Surgeon.names
    # @terms.each {|term| term.gsub!(/[\W]/, ' ')}
    @matches = []
    @term = params[:term]
    @terms.each {|t| @matches << t if /(#{@term})/.match(t.downcase)}
    render :json => @matches
  end

  def surgeons_only
    @terms = Surgeon.names
    # @terms.each {|term| term.gsub!(/[\W]/, ' ')}
    @matches = []
    @term = params[:term]
    @terms.each {|t| @matches << t if /(#{@term})/.match(t.downcase)}
    render :json => @matches
  end
end
