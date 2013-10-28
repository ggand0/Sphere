class AddColumnTextures < ActiveRecord::Migration
  def change
    add_column :textures, :texturable_id, :integer
    add_column :textures, :texturable_type, :string
  end
end
