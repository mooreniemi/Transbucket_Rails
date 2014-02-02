class PinsController < ApplicationController
before_filter :authenticate_user!

  # GET /pins
  # GET /pins.json
  def index
    @query = sanitize(params[:query]) if params[:query]
    @scope = params[:scope] if params[:scope]

    @presenter = PinPresenter.new(
                                  :query => @query,
                                  :scope => @scope,
                                  :user => current_user,
                                  :page => params[:page]
                                  )

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def by_user
    @presenter = PinPresenter.new(user: current_user)
    @pins = @presenter.by_user(User.find(params[:by_user]))
  end

  # GET /pins/1
  # GET /pins/1.json
  def show
    @pin = Pin.find(params[:id])
    @comments = @pin.comment_threads.order('created_at desc')
    @new_comment = Comment.build_from(@pin, current_user, "")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pin }
    end
  end

  def admin
    @pins = Pin.where(state: 'pending').order("created_at desc").paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pins }
    end
  end

  # GET /pins/new
  # GET /pins/new.json
  def new
    @pin = current_user.pins.new
    4.times {@pin.pin_images.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pin }
    end
  end

  # GET /pins/1/edit
  def edit
    @pin = Pin.find(params[:id])
    l = @pin.pin_images.length
    (4-l).times {@pin.pin_images.build}
  end

  # POST /pins
  # POST /pins.json
  #submit button triggers
  def create
    #nested associations are handled inside of the service
    @pin = PinCreatorService.new(params[:pin], current_user).create

    respond_to do |format|

      if @pin.save
        format.html { redirect_to @pin, notice: 'Pin was successfully created.' }
        format.json { render json: @pin, status: :created, location: @pin }
      else
        format.html { render action: "new" }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pins/1
  # PUT /pins/1.json
  def update
    @pin = Pin.find(params[:id])

    respond_to do |format|
      if PinUpdaterService.new(params[:pin].merge({pin_id: params[:id]}), current_user).update
        format.html { redirect_to @pin, notice: 'Pin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pins/1
  # DELETE /pins/1.json
  def destroy
    @pin = Pin.find(params[:id])
    @pin.destroy

    respond_to do |format|
      format.html { redirect_to pins_url }
      format.json { head :ok }
    end
  end

  private

  def sanitize(query)
    query.gsub!(/(dr.|Dr.|dr|Dr)/, '')
    query.gsub!(/[\W]/, ' ')
    return Riddle.escape(query)
  end
end
