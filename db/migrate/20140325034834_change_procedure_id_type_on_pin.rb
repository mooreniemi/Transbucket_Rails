class ChangeProcedureIdTypeOnPin < ActiveRecord::Migration[4.2]
  def up
  	change_column :pins, :procedure_id, 'integer USING CAST(procedure_id AS integer)'
  end

  def down
  	change_column :pins, :procedure_id, :string
  end
end
