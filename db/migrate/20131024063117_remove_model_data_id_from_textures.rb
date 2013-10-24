class RemoveModelDataIdFromTextures < ActiveRecord::Migration
  def change
    remove_column :textures, :modeldata_id
  end
end
