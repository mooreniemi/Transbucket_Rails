class SurgeonsController < ApplicationController
  def new
    @surgeon = Surgeon.new

    respond_to do |format|
      format.js
    end
  end

  def create
    @surgeon = Surgeon.new(params[:surgeon])

    if @surgeon.save!
      head :ok
    end
  end
end
