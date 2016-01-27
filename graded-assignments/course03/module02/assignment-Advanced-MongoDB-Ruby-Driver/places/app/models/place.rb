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

  def self.get_address_components(sort=nil, offset=0, limit=nil)
    if sort.nil? and limit.nil?
      Place.collection.aggregate([
        {:$unwind => '$address_components'}, 
        {:$project => { :_id=>1, :address_components=>1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$skip => offset}
      ])
    elsif sort.nil? and !limit.nil?
      Place.collection.aggregate([
        {:$unwind => '$address_components'}, 
        {:$project => { :_id=>1, :address_components=>1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$skip => offset}, 
        {:$limit => limit}
      ])
    elsif !sort.nil? and limit.nil?
      Place.collection.aggregate([
        {:$unwind => '$address_components'}, 
        {:$project => { :_id=>1, :address_components=>1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$sort => sort}, 
        {:$skip => offset}
      ])
    else
      Place.collection.aggregate([
        {:$unwind => '$address_components'}, 
        {:$project=>{ :_id=>1, :address_components=>1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$sort => sort}, 
        {:$skip => offset}, 
        {:$limit => limit}
      ])
    end
  end

  def self.get_country_names
    Place.collection.aggregate([
      {:$unwind => '$address_components'}, 
      {:$project=>{ :_id=>0, :address_components=> {:long_name => 1, :types => 1} }}, 
      {:$match => {'address_components.types': "country"  }}, {:$group=>{ :_id=>'$address_components.long_name', :count=>{:$sum=>1}}}
    ]).to_a.map {|h| h[:_id]}
  end

  def self.find_ids_by_country_code(s)
    Place.collection.aggregate([
      {:$unwind => '$address_components'}, 
      {:$project=>{ :_id=>1, :address_components=> {:short_name => 1, :types => 1} }}, 
      {:$match => {'address_components.short_name': s}}
    ]).map {|h| h[:_id].to_s}
  end

end
