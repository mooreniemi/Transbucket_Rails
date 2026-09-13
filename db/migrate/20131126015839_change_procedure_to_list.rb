class ChangeProcedureToList < ActiveRecord::Migration[4.2]
  def change
    rename_column :surgeons, :procedures, :procedure_list
  end
end
