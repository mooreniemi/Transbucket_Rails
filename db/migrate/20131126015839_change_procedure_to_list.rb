class ChangeProcedureToList < ActiveRecord::Migration
  def change
    rename_column :surgeons, :procedures, :procedure_list
  end
end
