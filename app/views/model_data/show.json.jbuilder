json.extract! @model_datum, :modeldata, :created_at, :updated_at
json.extract! @textures

json.id @model_datum.id
json.modeldata @data
json.textures @model_datum.textures
json.url @urls