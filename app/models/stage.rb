class Stage < ActiveRecord::Base  
    has_many :textures, :as => :texturable, :dependent => :destroy
    belongs_to :diorama
    
    accepts_nested_attributes_for :textures, allow_destroy: true
    #accepts_nested_attributes_for :scene_data
end
