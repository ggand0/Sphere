json.extract! @model_datum, :modeldata, :created_at, :updated_at
json.extract! @textures
#json.index_path model_data_path

#json.array! @model_datum, :id, :title
json.modeldata @model_datum.modeldata
json.textures @model_datum.textures[0]
json.url @textures.data.url