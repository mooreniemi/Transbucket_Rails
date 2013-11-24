class ChangeTypeOfNotes < ActiveRecord::Migration
  def self.up
     change_column :surgeons, :notes, :text
    end

    def self.down
     change_column :surgeons, :notes, :string
    end
end
