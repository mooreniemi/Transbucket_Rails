class ChangeTypeOfProcedures < ActiveRecord::Migration
  def self.up
     change_column :surgeons, :procedures, :text
    end

    def self.down
     change_column :surgeons, :procedures, :string
    end
end
