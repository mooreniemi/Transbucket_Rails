class SurgeonsController < ApplicationController
  def index
    @surgeons = Surgeon.all.order(:last_name)
    @pins_per_surgeon = Surgeon.joins(:pins).group("pins.surgeon_id").count
  end

  def show
    @surgeon = Surgeon.friendly.find(params[:id])
    # produces { procedure_id => count }, scoped to this surgeon rather than
    # grouping the entire pins table just to read one surgeon's slice of it
    @pins_by_surgeon_procedure = Pin.where(surgeon_id: @surgeon.id).group(:procedure_id).count
  end

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

  private
  def surgeon_params
    params.require(:surgeon).permit(:last_name, :first_name, :url)
  end
end
