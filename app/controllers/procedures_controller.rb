class ProceduresController < ApplicationController
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
        format.js  { @procedures = Procedure.order('name ASC') }
      end
    end
  end
end
