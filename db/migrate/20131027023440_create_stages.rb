class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :title
      t.string :scene_data

      t.timestamps
    end
  end
end
