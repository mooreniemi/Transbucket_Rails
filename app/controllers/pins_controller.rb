class PinsController < ApplicationController
  include SanitizeNames
  before_filter :authenticate_user!
  before_filter :validate_user, :only => [:edit, :update, :destroy]
  before_filter :get_pin, :except => [:index, :new, :create, :admin]
  respond_to :json

  # GET /pins
  # GET /pins.json
  def index
    @presenter = PinPresenter.new(pin_index_params)
    @comments = Comment.new_as_of(user_last_sign_in)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @comments = @pin.comments_asc
    @new_comment = Comment.build_from(@pin, current_user, "")

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

  # GET /pins/1/edit
  def edit
    @form = PinForm.new(current_user.pins.find(params[:id]))
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

        format.html { redirect_to @pin, notice: 'Pin was successfully created.' }
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
    @form = PinForm.new(current_user.pins.find(params[:id]))

    respond_to do |format|
      if @form.validate(pin_params)
        @form.save
        @pin = @form.model
        @pin.procedure.recalculate_avgs

        format.html { redirect_to @pin, notice: 'Pin was successfully updated.' }
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
        flash[:error] = "Could not destroy #{@pin.id}!"
        format.json { render json: @pin.errors.full_messages, status: :unprocessable_entity }
      else
        flash[:notice] = "Destroyed #{@pin.id}"
        format.json { render json: { status: 'destroyed' }, status: :ok }
      end
    end
  end

  def admin
    @pins = Pin.where(state: 'pending').order("created_at desc")
    @comments = Comment.where(state: 'pending').order("created_at desc")
    @queue = { pins: @pins, comments: @comments }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @queue }
    end
  end

  private
  def get_pin
    @pin = Pin.includes(comment_threads: [:children]).find(params[:id])
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
    pin_images = params.delete(:pin_images)
    params[:pin][:pin_images] = pin_images.values unless pin_images.nil?
    params[:pin][:surgeon] = id_or_attributes(params[:pin].delete(:surgeon_attributes))
    params[:pin][:procedure] = id_or_attributes(params[:pin].delete(:procedure_attributes))
    params.require(:pin).permit!
    # FIXME: why was this commented out? should it be removed?
    # params.require(:pin).permit(:surgeon_id, :procedure_id, :cost, :revision, :details, :sensation, :satisfaction,
    # pin_images: [:photo, :caption])
  end

  def pin_index_params
    {
      query: query,
      scope: params[:scope],
      surgeon: params[:surgeon],
      procedure: params[:procedure],
      complication: params[:complication],
      user: params[:user],
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

    if current_user == pin.user || current_user.admin
      return true
    else
      head :forbidden
    end
  end
end
