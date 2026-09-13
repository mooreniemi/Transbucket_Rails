class RenameSurgeonOnPin < ActiveRecord::Migration[4.2]
  def change
    rename_column :pins, :surgeon, :surgeon_id
    rename_column :pins, :procedure, :procedure_id
  end
end
