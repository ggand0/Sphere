class RenameFileNameToTitle < ActiveRecord::Migration
  def change
    rename_column :model_data, :fileName, :title
  end
end
