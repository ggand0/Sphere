class AddModelDataFilePaths < ActiveRecord::Migration
  def change
    add_column :model_data, :fileName, :string 
  end
end
