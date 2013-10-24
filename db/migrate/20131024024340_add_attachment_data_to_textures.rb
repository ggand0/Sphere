class AddAttachmentDataToTextures < ActiveRecord::Migration
  def self.up
    change_table :textures do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :textures, :data
  end
end
