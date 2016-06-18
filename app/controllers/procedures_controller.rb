class ProceduresController < ApplicationController
  def index
    @procedures = Procedure.all
  end

  def show
    @procedure = Procedure.friendly.find(params[:id])
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
