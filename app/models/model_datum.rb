class ModelDatum < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  
  #has_many :textures, :dependent => :destroy
  has_many :textures, :as => :texturable, :dependent => :destroy
  accepts_nested_attributes_for :textures, allow_destroy: true
end
