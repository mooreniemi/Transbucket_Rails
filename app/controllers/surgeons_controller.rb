class SurgeonsController < ApplicationController
  def new
    @surgeon = Surgeon.new

    respond_to do |format|
      format.js
    end
  end

  def create
  end
end
