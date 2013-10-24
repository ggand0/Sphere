class CreateModelData < ActiveRecord::Migration
  def change
    create_table :model_data do |t|
      t.string :modeldata

      t.timestamps
    end
  end
end
