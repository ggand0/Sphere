class Texture < ActiveRecord::Base
  belongs_to :texturable, :polymorphic => true
  
  Paperclip.interpolates :texturable_id do |attachment, style|
    "#{attachment.instance.texturable_id}"
  end
  Paperclip.interpolates :texturable_type do |attachment, style|
    "#{attachment.instance.texturable_type}"
  end
  
  has_attached_file :data,
    :url => '/system/:class/:attachment/:texturable_type/:texturable_id/:filename',
    :path => ':rails_root/public/system/:class/:attachment/:texturable_type/:texturable_id/:filename'
end
