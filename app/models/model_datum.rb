class ModelDatum < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  has_many :textures, :dependent => :destroy
  accepts_nested_attributes_for :textures, allow_destroy: true
end
