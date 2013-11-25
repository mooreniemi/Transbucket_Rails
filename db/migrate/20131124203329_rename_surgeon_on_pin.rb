class RenameSurgeonOnPin < ActiveRecord::Migration
  def change
    rename_column :pins, :surgeon, :surgeon_id
    rename_column :pins, :procedure, :procedure_id
  end
end
