class Texture < ActiveRecord::Base
  belongs_to :model_data
  has_attached_file :data
  
  #attr_accessible :model_datum_id

end
