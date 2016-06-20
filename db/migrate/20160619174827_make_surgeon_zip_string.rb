class MakeSurgeonZipString < ActiveRecord::Migration
  def up
    change_column :surgeons, :zip, :string
  end

  def down
    change_column :surgeons, :zip, 'integer USING CAST(zip AS integer)'
  end
end
