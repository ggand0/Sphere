class Texture < ActiveRecord::Base
  #belongs_to :model_data
  #belongs_to :stage
  belongs_to :texturable, :polymorphic => true
  
  has_attached_file :data
end
