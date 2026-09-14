class SurgeonsController < ApplicationController
  def index
    @surgeons = Surgeon.all.order(:last_name, :first_name)
    @pins_per_surgeon = Surgeon.joins(:pins).group("pins.surgeon_id").count
    @avg_satisfaction_by_surgeon = {}
    @avg_sensation_by_surgeon = {}
    if user_signed_in?
      @avg_satisfaction_by_surgeon = Pin.where.not(satisfaction: [nil, 0]).group(:surgeon_id).average(:satisfaction)
      @avg_sensation_by_surgeon = Pin.where.not(sensation: [nil, 0]).group(:surgeon_id).average(:sensation)
    end

  end

  def show
    @surgeon = Surgeon.friendly.find(params[:id])
    pins = Pin.where(surgeon_id: @surgeon.id)
    # Keep counts scoped to this surgeon, then load all referenced procedures
    # in one query instead of finding each procedure from the view.
    @pins_by_surgeon_procedure = pins.group(:procedure_id).count
    @procedures_by_id = Procedure.where(id: @pins_by_surgeon_procedure.keys).index_by(&:id)
    @satisfaction_by_procedure = pins.where.not(satisfaction: 0).group(:procedure_id).average(:satisfaction)
    @sensation_by_procedure = pins.where.not(sensation: 0).group(:procedure_id).average(:sensation)
    @procedure_count = @procedures_by_id.length
    @submission_count = @pins_by_surgeon_procedure.values.sum
    @latest_pins = nil
    @overall_satisfaction = nil
    @overall_sensation = nil
    @rating_distributions = nil
    @rating_distributions_by_procedure = nil
    if user_signed_in?
      @latest_pins = pins.recent.
        includes(:pin_images, :surgeon, :procedure).
        limit(3)
      @overall_satisfaction = pins.where.not(satisfaction: [nil, 0]).average(:satisfaction)
      @overall_sensation = pins.where.not(sensation: [nil, 0]).average(:sensation)
      @rating_distributions = rating_distributions_for(pins)
      @rating_distributions_by_procedure = rating_distributions_by_procedure_for(pins)
    end
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

  def rating_distributions_for(pins)
    {
      sensation: pins.where(sensation: 1..5).group(:sensation).count,
      satisfaction: pins.where(satisfaction: 1..5).group(:satisfaction).count
    }
  end

  def rating_distributions_by_procedure_for(pins)
    distributions = Hash.new do |hash, procedure_id|
      hash[procedure_id] = { sensation: {}, satisfaction: {} }
    end

    pins.where(sensation: 1..5).group(:procedure_id, :sensation).count.each do |(procedure_id, score), count|
      distributions[procedure_id][:sensation][score] = count
    end
    pins.where(satisfaction: 1..5).group(:procedure_id, :satisfaction).count.each do |(procedure_id, score), count|
      distributions[procedure_id][:satisfaction][score] = count
    end
    distributions
  end
end
