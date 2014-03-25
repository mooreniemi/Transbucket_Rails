class ChangeProcedureIdOnPin < ActiveRecord::Migration
  def up
  	change_column :pins, :procedure_id, :integer
  end

  def down
  	change_column :pins, :procedure_id, :string
  end
end
