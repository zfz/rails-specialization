# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

mongo_client = Mongoid::Clients.default

puts "Seed DB: clear photos"
Photo.mongo_client.database.fs.find.each { |photo|
  photo_id = photo[:_id].to_s
  p = Photo.find(photo_id)
  p.destroy
}

puts "Seed DB: clear places"
mongo_client[:places].delete_many()

puts "Seed DB: create index"
mongo_client[:places].indexes.create_one(
  {'geometry.geolocation': Mongo::Index::GEO2DSPHERE}
)

puts "Seed DB: load places"
place_file = File.open("./db/places.json")
Place.load_all(place_file)

puts "Seed DB: load photos"
Dir.glob("./db/image*.jpg").each { |file_name| 
  p = Photo.new 
  f = File.open(file_name)
  f.rewind
  p.contents = f 
  id = p.save
}  

puts "Seed DB: match photo with place"
Photo.all.each { |photo|
  place_id = photo.find_nearest_place_id(1609.34)
  photo_id = photo.id.to_s
  p = Photo.find(photo_id)
  p.place = place_id
  p.save
}
