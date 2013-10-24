json.array!(@model_data) do |model_datum|
  json.extract! model_datum, :modeldata
  json.url model_datum_url(model_datum, format: :json)
end
