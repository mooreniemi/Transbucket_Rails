class ProceduresController < ApplicationController
  def index
    @procedures = Procedure.all.order(:name)
    @pins_per_procedure = Procedure.joins(:pins).group("pins.procedure_id").count
    @comments_per_procedure = Procedure.joins(:comment_threads).group("comments.commentable_id").count
    @avg_satisfaction_by_procedure = Pin.where.not(satisfaction: [nil, 0]).group(:procedure_id).average(:satisfaction)
    @avg_sensation_by_procedure = Pin.where.not(sensation: [nil, 0]).group(:procedure_id).average(:sensation)

  end

  def show
    @procedure = Procedure.includes(comment_threads: [:children]).friendly.find(params[:id])
    guide = @procedure.editorial_guide
    @related_procedures = @procedure.related_procedures
    # procedure pages are public, but comments should be private
    if current_user
      @comments = @procedure.comments_asc
      @new_comment = Comment.build_from(@procedure, current_user, "")
      @safe_mode = current_user.preference.present? && UserPolicy.new(current_user).safe_mode?
      @latest_pins = @procedure.pins.where(state: 'published').
        includes(:pin_images, :surgeon, :procedure).
        order(updated_at: :desc).
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
end
