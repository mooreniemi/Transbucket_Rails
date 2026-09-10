class CreateProcedureTranslations < ActiveRecord::Migration
  def change
    create_table :procedure_translations do |t|
      t.references :procedure, null: false
      t.string :locale, null: false
      t.string :name, null: false
      t.timestamps null: false
    end

    add_index :procedure_translations, [:procedure_id, :locale], unique: true
    add_index :procedure_translations, [:locale, :name]
    add_foreign_key :procedure_translations, :procedures
  end
end
