class CreateDioramas < ActiveRecord::Migration
  def change
    create_table :dioramas do |t|
      t.string :title

      t.timestamps
    end
  end
end
