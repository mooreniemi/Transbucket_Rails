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
    procedures = [@first_procedure, @second_procedure].compact
    @comparison_scope_options = common_surgeons_for(procedures)
    @comparison_surgeon = find_common_surgeon(params[:surgeon_id], procedures)
    @comparison_data = procedure_comparison_data(procedures, @comparison_surgeon)
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

  def find_common_surgeon(identifier, procedures)
    return if identifier.blank? || procedures.length < 2

    surgeon = Surgeon.friendly.find(identifier)
    common_surgeons_for(procedures).include?(surgeon) ? surgeon : nil
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def common_surgeons_for(procedures)
    return Surgeon.order(:last_name, :first_name) if procedures.length < 2

    ids = procedures.map { |procedure| Pin.where(procedure_id: procedure.id).where.not(surgeon_id: nil).distinct.pluck(:surgeon_id) }
    common_ids = ids.reduce { |common, current| common & current } || []
    Surgeon.where(id: common_ids).order(:last_name, :first_name)
  end

  def procedure_comparison_data(procedures, surgeon = nil)
    data = procedures.each_with_object({}) do |procedure, result|
      result[procedure] = { distributions: { sensation: {}, satisfaction: {} }, averages: {} }
    end
    ids = procedures.map(&:id)
    pins = Pin.where(procedure_id: ids)
    pins = pins.where(surgeon_id: surgeon.id) if surgeon

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
    published_pins = pins.published
    submission_counts = published_pins.group(:procedure_id).count
    surgeon_counts = published_pins.where.not(surgeon_id: nil).group(:procedure_id).distinct.count(:surgeon_id)
    complication_counts = published_pins.
      joins('INNER JOIN taggings ON taggings.taggable_id = pins.id AND taggings.taggable_type = \'Pin\' AND taggings.context = \'complications\'').
      joins('INNER JOIN tags ON tags.id = taggings.tag_id').
      group('pins.procedure_id', 'tags.name').count

    data.each do |procedure, values|
      procedure_id = procedure.id
      values[:stats] = {
        submissions: submission_counts[procedure_id].to_i,
        surgeons: surgeon_counts[procedure_id].to_i,
        outcomes: [:sensation, :satisfaction].each_with_object({}) do |rating, outcomes|
          counts = values[:distributions][rating]
          rated = counts.values.sum
          good = counts.select { |score, _count| score >= 3 }.values.sum
          challenging = counts[1].to_i
          outcomes[rating] = {
            good: rated.zero? ? nil : (good.to_f / rated * 100).round(1),
            challenging: rated.zero? ? nil : (challenging.to_f / rated * 100).round(1)
          }
        end,
        complications: complication_counts.each_with_object([]) do |((group_procedure_id, name), count), complications|
          next unless group_procedure_id == procedure_id

          complications << {
            name: name,
            count: count,
            rate: (count.to_f / submission_counts[procedure_id].to_i * 100).round(1)
          }
        end.sort_by { |complication| -complication[:count] }.first(10)
      }
    end
    data
  end
end
