require 'json'

class Place
  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params)
    @id = params[:_id].to_s

    @address_components = []
    address_components = params[:address_components]
    address_components.each { |a| @address_components << AddressComponent.new(a) }

    @formatted_address = params[:formatted_address]
    @location = Point.new(params[:geometry][:geolocation])
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client[:places]
  end

  def self.load_all(f)
    h = JSON.parse(f.read)
    collection.insert_many(h)
  end

  def self.find_by_short_name(s)
    Place.collection.find({"address_components.short_name": s})
  end

  def self.to_places ms
    p = []
    ms.each { |m| 
      p << Place.new(m) 
    }
    return p
  end

  def self.find s
    _id = BSON::ObjectId.from_string(s)
    p = collection.find(:_id => _id).first
    if !p.nil?
      Place.new(p)
    else
      nil
    end
  end

  def self.all(offset=0, limit=nil)
    if !limit.nil?
      docs = collection.find.skip(offset).limit(limit)
    else
      docs = collection.find.skip(offset)
    end

    docs.map { |doc|
      Place.new(doc)
    }
  end

  def destroy
    self.class.collection.find(:_id => BSON::ObjectId.from_string(@id)).delete_one
  end

end
