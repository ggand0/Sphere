class CreateModelTransforms < ActiveRecord::Migration
  def change
    create_table :model_transforms do |t|

      t.timestamps
    end
  end
end
