class SearchController < ApplicationController
  respond_to :json

  def search_terms
    matches = FuzzyMatch.new(all_keywords).find(term)
    render :json => {:match => matches}.to_json
  end

  def surgeons_only
    matches = FuzzyMatch.new(surgeons).find(term)
    render :json => {:match => matches}.to_json
  end

  private
  def all_keywords
    procedures + surgeons
  end

  def procedures
    Procedure.names
  end

  def surgeons
    Surgeon.names
  end

  def term
    params.permit(:term)[:term]
  end
end
