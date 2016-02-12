json.array!(@racers) do |racer|
  json.extract! racer, :id, :first_name, :last_name, :gender, :birth_year, :city, :state
  json.url racer_url(racer, format: :json)
end
