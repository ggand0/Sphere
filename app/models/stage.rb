class Stage < ActiveRecord::Base  
    has_many :textures, :as => :texturable, :dependent => :destroy
    accepts_nested_attributes_for :textures, allow_destroy: true
end
