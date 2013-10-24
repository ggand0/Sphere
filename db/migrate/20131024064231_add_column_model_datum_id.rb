class AddColumnModelDatumId < ActiveRecord::Migration
  def change
    add_column :textures, :model_datum_id, :integer
  end
end
