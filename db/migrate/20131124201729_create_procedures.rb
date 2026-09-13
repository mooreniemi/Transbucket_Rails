class CreateProcedures < ActiveRecord::Migration[4.2]
  def change
    create_table :procedures do |t|
      t.string :name

      t.timestamps
    end
  end
end
