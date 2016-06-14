class ChangeSurgeonPhone < ActiveRecord::Migration
  def change
    change_column :surgeons, :phone, :string, :limit => 20
  end
end
