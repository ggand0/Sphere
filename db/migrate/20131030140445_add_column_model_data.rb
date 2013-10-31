class AddColumnModelData < ActiveRecord::Migration
  def change
    add_column :model_data, :diorama_id, :integer
  end
end
