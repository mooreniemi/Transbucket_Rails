class ChangeTypeOfNotes < ActiveRecord::Migration[4.2]
  def self.up
     change_column :surgeons, :notes, :text
    end

    def self.down
     change_column :surgeons, :notes, :string
    end
end
