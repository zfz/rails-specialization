json.array!(@races) do |race|
  json.extract! race, :id, :name, :date, :city, :state, :swim_distance, :swim_units, :bike_distance, :bike_units, :run_distance, :run_units
  json.url race_url(race, format: :json)
end
