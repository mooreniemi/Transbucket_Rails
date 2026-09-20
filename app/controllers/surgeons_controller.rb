class SurgeonsController < ApplicationController
  before_filter :authenticate_user!, only: :compare

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
    @comparison_options = Surgeon.order(:last_name, :first_name)
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

  def compare
    @comparison_options = Surgeon.order(:last_name, :first_name)
    @comparison_scope_memberships = comparison_scope_memberships(@comparison_options, :surgeon_id, :procedure_id, Procedure)
    @deduplicate = params[:deduplicate] != '0'
    @first_surgeon = find_comparison_record(params[:first_id])
    @second_surgeon = find_comparison_record(params[:second_id])
    surgeons = [@first_surgeon, @second_surgeon].compact
    @comparison_scope_options = common_procedures_for(surgeons)
    @comparison_procedure = find_common_procedure(params[:procedure_id], surgeons)
    @comparison_data = surgeon_comparison_data(surgeons, @comparison_procedure, @deduplicate)
    @comparison_cache_version = comparison_cache_version(surgeons, @comparison_procedure)
    @comparison_evidence = ComparisonStatistics.for(
      @comparison_data[@first_surgeon] || { distributions: { sensation: {}, satisfaction: {} } },
      @comparison_data[@second_surgeon] || { distributions: { sensation: {}, satisfaction: {} } }
    )
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

  def find_comparison_record(identifier)
    return if identifier.blank?

    Surgeon.friendly.find(identifier)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def find_common_procedure(identifier, surgeons)
    return if identifier.blank? || surgeons.length < 2

    procedure = Procedure.friendly.find(identifier)
    common_procedures_for(surgeons).include?(procedure) ? procedure : nil
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def common_procedures_for(surgeons)
    return Procedure.order(:name) if surgeons.length < 2

    ids = surgeons.map { |surgeon| Pin.where(surgeon_id: surgeon.id).where.not(procedure_id: nil).distinct.pluck(:procedure_id) }
    common_ids = ids.reduce { |common, current| common & current } || []
    Procedure.where(id: common_ids).order(:name)
  end

  def comparison_scope_memberships(records, record_column, scope_column, scope_class)
    ids = records.map(&:id)
    return {} if ids.empty?

    pairs = Pin.where(record_column => ids).where.not(scope_column => nil).distinct.pluck(record_column, scope_column)
    scopes = scope_class.where(id: pairs.map(&:last)).index_by(&:id)
    pairs.
      group_by(&:first).
      each_with_object({}) do |(record_id, pairs), memberships|
        record = records.find { |candidate| candidate.id == record_id }
        memberships[record.to_param] = pairs.map { |pair| scopes[pair.last].to_param }
      end
  end

  def surgeon_comparison_data(surgeons, procedure = nil, deduplicate = true)
    data = surgeons.each_with_object({}) do |surgeon, result|
      result[surgeon] = { distributions: { sensation: {}, satisfaction: {} }, averages: {} }
    end
    ids = surgeons.map(&:id)
    pins = Pin.where(surgeon_id: ids)
    pins = pins.where(procedure_id: procedure.id) if procedure
    pins = deduplicated_pins(pins, :procedure_id) if deduplicate

    pins.where(sensation: 1..5).group(:surgeon_id, :sensation).count.each do |(surgeon_id, score), count|
      data[surgeons.find { |surgeon| surgeon.id == surgeon_id }][:distributions][:sensation][score] = count
    end
    pins.where(satisfaction: 1..5).group(:surgeon_id, :satisfaction).count.each do |(surgeon_id, score), count|
      data[surgeons.find { |surgeon| surgeon.id == surgeon_id }][:distributions][:satisfaction][score] = count
    end
    pins.where(sensation: 1..5).group(:surgeon_id).average(:sensation).each do |surgeon_id, average|
      surgeon = surgeons.find { |candidate| candidate.id == surgeon_id }
      data[surgeon][:averages][:sensation] = average
    end
    pins.where(satisfaction: 1..5).group(:surgeon_id).average(:satisfaction).each do |surgeon_id, average|
      surgeon = surgeons.find { |candidate| candidate.id == surgeon_id }
      data[surgeon][:averages][:satisfaction] = average
    end
    published_pins = pins.published
    submission_counts = published_pins.group(:surgeon_id).count
    procedure_counts = published_pins.where.not(procedure_id: nil).group(:surgeon_id).distinct.count(:procedure_id)
    complication_counts = published_pins.
      joins('INNER JOIN taggings ON taggings.taggable_id = pins.id AND taggings.taggable_type = \'Pin\' AND taggings.context = \'complications\'').
      joins('INNER JOIN tags ON tags.id = taggings.tag_id').
      group('pins.surgeon_id', 'tags.name').count

    data.each do |surgeon, values|
      surgeon_id = surgeon.id
      values[:stats] = {
        submissions: submission_counts[surgeon_id].to_i,
        procedures: procedure_counts[surgeon_id].to_i,
        outcomes: [:sensation, :satisfaction].each_with_object({}) do |rating, outcomes|
          counts = values[:distributions][rating]
          rated = counts.values.sum
          good = counts.select { |score, _count| score >= 3 }.values.sum
          challenging = counts[1].to_i
          outcomes[rating] = {
            good: rated.zero? ? nil : (good.to_f / rated * 100).round,
            challenging: rated.zero? ? nil : (challenging.to_f / rated * 100).round
          }
        end,
        complications: complication_counts.each_with_object([]) do |((group_surgeon_id, name), count), complications|
          next unless group_surgeon_id == surgeon_id

          complications << {
            name: name,
            count: count,
            rate: (count.to_f / submission_counts[surgeon_id].to_i * 100).round
          }
        end.sort_by { |complication| [-complication[:count], complication[:name].downcase] }
      }
    end
    data
  end

  def comparison_cache_version(surgeons, procedure = nil)
    pins = Pin.where(surgeon_id: surgeons.map(&:id))
    pins = pins.where(procedure_id: procedure.id) if procedure
    [pins.count, pins.maximum(:updated_at)]
  end

  def deduplicated_pins(pins, scope_column)
    eligible = pins.where.not(user_id: nil).where.not(scope_column => nil)
    representative_ids = eligible.select("DISTINCT ON (user_id, #{scope_column}, surgeon_id) pins.id").
      reorder(nil).
      order("user_id, #{scope_column}, surgeon_id, created_at DESC, id DESC")
    null_scope_sql = "pins.user_id IS NULL OR pins.#{scope_column} IS NULL"
    pins.where("#{null_scope_sql} OR pins.id IN (?)", representative_ids)
  end
end
