class ProceduresController < ApplicationController
  respond_to :json

  def new
    @procedure = Procedure.new

    respond_to do |format|
      format.js
    end
  end

  def create
    @procedure = Procedure.new(params[:procedure])

    if @procedure.save
      respond_to do |format|
        format.js { render 'create', layout: false}
      end
    end
  end
end
