class ModelDatum < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  #has_many :textures, :dependent => :destroy
  has_many :textures, :as => :texturable, :dependent => :destroy
  has_many :model_transforms, :dependent => :destroy
  has_many :dioramas, :through => :model_transforms
  
  accepts_nested_attributes_for :textures, allow_destroy: true
  accepts_nested_attributes_for :model_transforms, allow_destroy: true
end
