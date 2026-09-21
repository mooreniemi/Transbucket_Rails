class PinsController < ApplicationController
  include SanitizeNames
  before_filter :authenticate_user!
  before_filter :validate_user, :only => [:edit, :update, :destroy]
  before_filter :require_moderator!, :only => :admin
  before_filter :get_pin, :except => [:index, :new, :create, :admin, :complication_suggestions]
  respond_to :json

  # GET /pins
  # GET /pins.json
  def index
    @presenter = PinPresenter.new(pin_index_params)
    @comments = Comment.new_as_of(user_last_sign_in)
    @comment_counts = Comment.published_counts_for('Pin', @presenter.pins.map(&:id))
    # The card's "new comment" snippet: the newest published comment on each pin since
    # the last sign-in, picked from the comments loaded above (no query per card).
    @latest_new_comments = @comments.select { |comment| comment.commentable_type == 'Pin' }
                                    .group_by(&:commentable_id)
                                    .each_with_object({}) { |(pin_id, group), latest| latest[pin_id] = group.max_by(&:created_at) }
    # Pin cards are fragment-cached by this value, so set it before rendering
    # rather than relying on an unset instance variable in the partial.
    @safe_mode = safe_mode
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @comments = @pin.comments_asc
    ActiveRecord::Associations::Preloader.new.preload(@comments, user: :trust_grants)
    @new_comment = Comment.build_from(@pin, current_user, "")
    @safe_mode = safe_mode

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  # GET /pins/new
  # GET /pins/new.json
  def new
    @form = PinForm.new(current_user.pins.new)
    @form.prepopulate!
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @form.model }
    end
  end

  def complication_suggestions
    term = params[:term].to_s.strip.downcase[0, 80]
    return render json: [] if term.blank?

    # Only suggest tags that are actually used in Pin complication taggings.
    # Keep this prefix-based and bounded so the endpoint stays cheap as the
    # tag vocabulary grows.
    term = term.gsub(/[%_\\]/, '')
    suggestions = ActsAsTaggableOn::Tag.
      joins('INNER JOIN taggings ON taggings.tag_id = tags.id').
      where(taggings: { taggable_type: 'Pin', context: 'complications' }).
      where('LOWER(tags.name) LIKE ?', "#{term}%").
      select('DISTINCT tags.name').
      order('tags.name').
      limit(8).
      map(&:name)

    render json: suggestions
  end

  # GET /pins/1/edit
  def edit
    # validate_user has already authorized @pin for either its owner or an
    # admin. Re-scoping through current_user.pins here turned an authorized
    # admin request into RecordNotFound for another user's pin.
    @form = PinForm.new(@pin)
    @form.prepopulate!
  end

  # POST /pins
  # POST /pins.json
  def create
    @form = PinForm.new(current_user.pins.new)

    respond_to do |format|
      if @form.validate(pin_params)
        @form.save
        @pin = @form.model
        @pin.procedure.recalculate_avgs

        format.html { redirect_to @pin, notice: t('flash.pin_created') }
        format.json { render json: @pin, status: :created, location: @pin }
      else
        format.html { render action: 'new' }
        format.json { render json: @form.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pins/1
  # PUT /pins/1.json
  def update
    @form = PinForm.new(@pin)

    respond_to do |format|
      if @form.validate(pin_params)
        @form.save
        @pin = @form.model
        @pin.procedure.recalculate_avgs

        format.html { redirect_to @pin, notice: t('flash.pin_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @form.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pins/1
  # DELETE /pins/1.json
  def destroy
    @pin.destroy

    respond_to do |format|
      if Pin.find_by_id(@pin.id)
        flash[:error] = t('flash.destroy_failed', id: @pin.id)
        format.json { render json: @pin.errors.full_messages, status: :unprocessable_entity }
      else
        flash[:notice] = t('flash.destroyed', id: @pin.id)
        format.json { render json: { status: 'destroyed' }, status: :ok }
      end
    end
  end

  def admin
    @pins = Pin.where(state: 'pending').order("created_at desc")
    @comments = Comment.where(state: 'pending').order("created_at desc")
    @moderation_stats = moderation_stats(@pins, @comments)
    @queue = { pins: @pins, comments: @comments }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @queue }
    end
  end

  private

  def moderation_stats(pins, comments)
    {
      current_flags: current_flag_counts(pins, comments),
      lifetime_flags: lifetime_flag_counts(pins, comments),
      current_flaggers: current_flaggers(pins, comments),
      top_flaggers: ModerationEvent.where(action: 'flag').select('user_id, COUNT(*) AS flag_count').group(:user_id).order('COUNT(*) DESC').limit(10),
      top_flagged: ModerationEvent.where(action: 'flag').select('content_type, content_id, COUNT(*) AS flag_count').group(:content_type, :content_id).order('COUNT(*) DESC').limit(10)
    }
  end

  def current_flag_counts(pins, comments)
    counts = {}
    ActsAsVotable::Vote.where(votable_type: 'Pin', votable_id: pins.map(&:id), vote_flag: false).group(:votable_id).count.each do |id, count|
      counts[['Pin', id]] = count
    end
    ActsAsVotable::Vote.where(votable_type: 'Comment', votable_id: comments.map(&:id), vote_flag: false).group(:votable_id).count.each do |id, count|
      counts[['Comment', id]] = count
    end
    counts
  end

  def lifetime_flag_counts(pins, comments)
    ids_by_type = { 'Pin' => pins.map(&:id), 'Comment' => comments.map(&:id) }
    ids_by_type.each_with_object({}) do |(type, ids), counts|
      ModerationEvent.where(action: 'flag', content_type: type, content_id: ids).group(:content_id).count.each do |id, count|
        counts[[type, id]] = count
      end
    end
  end

  def current_flaggers(pins, comments)
    ids_by_type = { 'Pin' => pins.map(&:id), 'Comment' => comments.map(&:id) }
    ids_by_type.each_with_object({}) do |(type, ids), flaggers|
      ActsAsVotable::Vote.where(votable_type: type, votable_id: ids, vote_flag: false).includes(:voter).group_by(&:votable_id).each do |id, votes|
        flaggers[[type, id]] = votes
      end
    end
  end

  def get_pin
    @pin = Pin.includes(user: :trust_grants, comment_threads: [:children]).find(params[:id])
  end

  def id_or_attributes(attributes)
    return nil if attributes.nil?

    id = attributes.delete("id")

    if attributes["name"].present?
      attributes
    elsif !attributes.has_key?("name") and attributes.values.any?(&:present?)
      attributes
    else
      {"id" => id}
    end
  end

  def pin_params
    # The JS (dropzone) upload path submits images as a top-level :pin_images
    # param; the plain form path submits them nested as :pin_images_attributes,
    # same as Rails' usual fields_for convention. Both get normalized to
    # params[:pin][:pin_images] below.
    pin_images = params.delete(:pin_images) || params[:pin].delete(:pin_images_attributes)
    params[:pin][:pin_images] = pin_images.values unless pin_images.nil?
    params[:pin][:surgeon] = id_or_attributes(params[:pin].delete(:surgeon_attributes))
    params[:pin][:procedure] = id_or_attributes(params[:pin].delete(:procedure_attributes))
    # Explicit whitelist, replacing a bare `permit!`. Notably excludes user_id
    # (server-set only, see PinForm) and Procedure's avg_sensation/
    # avg_satisfaction (computed server-side by Procedure#recalculate_avgs,
    # never user-settable) -- both were previously reachable through permit!.
    params.require(:pin).permit(
      :cost, :covered_by_insurance, :revision, :sensation, :satisfaction, :complication_list, :complications_present, :details, :description,
      surgeon: [:id, :last_name, :first_name, :url],
      procedure: [:id, :name, :body_type, :gender, :description],
      pin_images: [:id, :photo, :caption, :_destroy]
    )
  end

  def pin_index_params
    {
      query: query,
      scope: params[:scope],
      surgeon: params[:surgeon],
      procedure: params[:procedure],
      complication: params[:complication],
      user: params[:user],
      satisfaction: params[:satisfaction],
      sensation: params[:sensation],
      feed: params[:feed],
      current_user: current_user,
      page: params[:page]
    }
  end

  def query
    sanitize_query(params[:query]) if params[:query]
  end

  def safe_mode
    current_user.preference.present? ? UserPolicy.new(current_user).safe_mode? : false
  end

  def user_last_sign_in
    User.find(current_user.id).try(:last_sign_in_at)
  end

  def validate_user
    pin = Pin.find(params[:id])

    if current_user == pin.user || current_user.admin? || (action_name == 'destroy' && current_user.moderator?)
      return true
    else
      head :forbidden
    end
  end

  def require_moderator!
    head :forbidden unless current_user.moderator?
  end
end
