class SurgeonsController < ApplicationController
  def new
    @surgeon = Surgeon.new

    respond_to do |format|
      format.js
    end
  end

  def create
    @surgeon = Surgeon.new(params[:surgeon])

    if @surgeon.save
      respond_to do |format|
        format.js  { @surgeons = Surgeon.order('last_name ASC'); @surgeon }
      end
    end
  end
end
