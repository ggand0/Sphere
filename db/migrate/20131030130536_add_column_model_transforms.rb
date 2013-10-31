class AddColumnModelTransforms < ActiveRecord::Migration
  def change
    add_column :model_transforms, :transform, :string
    add_column :model_transforms, :diorama_id, :integer
    add_column :model_transforms, :model_datum_id, :integer
  end
end
