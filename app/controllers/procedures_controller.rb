class ProceduresController < ApplicationController
  before_filter :authenticate_user!, only: :compare

  def index
    @procedures = Procedure.all.order(:name)
    @pins_per_procedure = Procedure.joins(:pins).group("pins.procedure_id").count
    @comments_per_procedure = Procedure.joins(:comment_threads).group("comments.commentable_id").count
    @avg_satisfaction_by_procedure = Pin.where.not(satisfaction: [nil, 0]).group(:procedure_id).average(:satisfaction)
    @avg_sensation_by_procedure = Pin.where.not(sensation: [nil, 0]).group(:procedure_id).average(:sensation)

  end

  def show
    @procedure = Procedure.includes(comment_threads: [:children]).friendly.find(params[:id])
    @comparison_options = Procedure.order(:name)
    guide = @procedure.editorial_guide
    @related_procedures = @procedure.related_procedures
    # procedure pages are public, but comments should be private
    if current_user
      @comments = @procedure.comments_asc
      @new_comment = Comment.build_from(@procedure, current_user, "")
      @safe_mode = current_user.preference.present? && UserPolicy.new(current_user).safe_mode?
      @latest_pins = @procedure.pins.recent.
        includes(:pin_images, :surgeon, :procedure).
        limit(3)
      @rating_distributions = {
        sensation: @procedure.pins.where(sensation: 1..5).group(:sensation).count,
        satisfaction: @procedure.pins.where(satisfaction: 1..5).group(:satisfaction).count
      }
      @rating_averages = {
        sensation: @procedure.pins.where(sensation: 1..5).average(:sensation),
        satisfaction: @procedure.pins.where(satisfaction: 1..5).average(:satisfaction)
      }
    end
  end

  def compare
    @comparison_options = Procedure.order(:name)
    @first_procedure = find_comparison_record(params[:first_id])
    @second_procedure = find_comparison_record(params[:second_id])
    @comparison_data = procedure_comparison_data([@first_procedure, @second_procedure].compact)
  end

  def new
    @procedure = Procedure.new

    respond_to do |format|
      format.js
    end
  end

  def create
    @procedure = Procedure.new(procedure_params)

    if @procedure.save
      respond_to do |format|
        format.js  { @procedures = Procedure.order('name ASC'); @procedure }
      end
    end
  end

  private
  def procedure_params
    params.require(:procedure).permit(:name, :body_type, :gender)
  end

  def find_comparison_record(identifier)
    return if identifier.blank?

    Procedure.friendly.find(identifier)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def procedure_comparison_data(procedures)
    data = procedures.each_with_object({}) do |procedure, result|
      result[procedure] = { distributions: { sensation: {}, satisfaction: {} }, averages: {} }
    end
    ids = procedures.map(&:id)
    pins = Pin.where(procedure_id: ids)

    pins.where(sensation: 1..5).group(:procedure_id, :sensation).count.each do |(procedure_id, score), count|
      data[procedures.find { |procedure| procedure.id == procedure_id }][:distributions][:sensation][score] = count
    end
    pins.where(satisfaction: 1..5).group(:procedure_id, :satisfaction).count.each do |(procedure_id, score), count|
      data[procedures.find { |procedure| procedure.id == procedure_id }][:distributions][:satisfaction][score] = count
    end
    pins.where(sensation: 1..5).group(:procedure_id).average(:sensation).each do |procedure_id, average|
      procedure = procedures.find { |candidate| candidate.id == procedure_id }
      data[procedure][:averages][:sensation] = average
    end
    pins.where(satisfaction: 1..5).group(:procedure_id).average(:satisfaction).each do |procedure_id, average|
      procedure = procedures.find { |candidate| candidate.id == procedure_id }
      data[procedure][:averages][:satisfaction] = average
    end
    data
  end
end
