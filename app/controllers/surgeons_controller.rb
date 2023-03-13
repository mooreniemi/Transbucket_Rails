class SurgeonsController < ApplicationController
  def index
    @surgeons = Surgeon.all.order(:last_name)
    @pin_counts_per_surgeon = Surgeon.joins(:pins).group("pins.surgeon_id").count
    @pins_per_surgeon = Hash[*Pin.select(:surgeon_id, 'array_agg(id)').group(:surgeon_id).pluck(:surgeon_id, 'array_agg(id)').flatten(1)]
    @pins_by_complications = ActsAsTaggableOn::Tagging.includes(:tag).
      where(context: 'complications').
      pluck(:taggable_id, :name).group_by {|id, name| id }
  end

  def show
    @surgeon = Surgeon.friendly.find(params[:id])
    # produces {[surgeon_id, procedure_id] => count }
    @pins_by_surgeon_procedure = Pin.group(:surgeon_id, :procedure_id).count
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
