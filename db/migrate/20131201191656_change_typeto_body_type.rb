class ChangeTypetoBodyType < ActiveRecord::Migration
  def change
    rename_column :procedures, :type, :body_type
  end
end
