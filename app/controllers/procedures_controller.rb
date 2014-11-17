class ProceduresController < ApplicationController
  def new
    @procedure = Procedure.new

    respond_to do |format|
      format.js
    end
  end

  def create
  end
end
