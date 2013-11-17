json.extract! @model_datum, :modeldata, :created_at, :updated_at
json.extract! @textures
#json.index_path model_data_path

#json.array! @model_datum, :id, :title
json.id @model_datum.id
json.modeldata @model_datum.modeldata
if @model_datum.textures != nil && @textures != nil
	json.textures @model_datum.textures
	
	urls = []
	for texture in @model_datum.textures
		urls << texture.data.url
	end
	#json.url @model_datum.textures[0].data.url
	json.url urls
end