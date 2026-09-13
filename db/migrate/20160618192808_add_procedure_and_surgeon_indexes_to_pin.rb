class AddProcedureAndSurgeonIndexesToPin < ActiveRecord::Migration[4.2]
  def change
    add_index :pins, :surgeon_id
    add_index :pins, :procedure_id
  end
end
