class Diorama < ActiveRecord::Base
  has_one :stage
  has_many :model_transforms
  has_many :model_datum, :through => :model_transforms
  
  accepts_nested_attributes_for :model_transforms, allow_destroy: true
  accepts_nested_attributes_for :model_datum
end
