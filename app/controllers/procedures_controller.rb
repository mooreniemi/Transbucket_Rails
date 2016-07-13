class ProceduresController < ApplicationController
  def index
    @procedures = Procedure.all
  end

  def show
    @procedure = Procedure.includes(:comment_threads).friendly.find(params[:id])
    # procedure pages are public, but comments should be private
    if current_user
      @comments = @procedure.comments_desc
      @new_comment = Comment.build_from(@procedure, current_user, "")
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
