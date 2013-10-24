class CreateTextures < ActiveRecord::Migration
  def change
    create_table :textures do |t|
      t.integer :modeldata_id

      t.timestamps
    end
  end
end
