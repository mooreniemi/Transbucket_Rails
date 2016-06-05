class SurgeonsController < ApplicationController
  def new
    @surgeon = Surgeon.new

    respond_to do |format|
      format.js
    end
  end

  def create
    @surgeon = Surgeon.new(surgeon_params)

    if @surgeon.save
      respond_to do |format|
        format.js  { @surgeons = Surgeon.order('last_name ASC'); @surgeon }
      end
    end
  end

  def surgeon_params
    params.require(:surgeon).permit(:last_name, :first_name, :url)
  end
end
