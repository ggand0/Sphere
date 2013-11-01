class AddColumnStages < ActiveRecord::Migration
  def change
    add_column :stages, :diorama_id, :integer
  end
end
