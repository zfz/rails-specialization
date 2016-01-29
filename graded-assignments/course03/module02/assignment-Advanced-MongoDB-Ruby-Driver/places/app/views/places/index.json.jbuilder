json.array!(@places) do |place|
  json.extract! place, :id, :formatted_address
  json.url place_url(place, format: :json)
end
