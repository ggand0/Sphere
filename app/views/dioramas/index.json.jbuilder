json.array!(@dioramas) do |diorama|
  json.extract! diorama, :title
  json.url diorama_url(diorama, format: :json)
end
