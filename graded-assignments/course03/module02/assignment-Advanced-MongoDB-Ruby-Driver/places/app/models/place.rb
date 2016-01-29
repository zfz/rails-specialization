require 'json'

class Place
  include ActiveModel::Model
  attr_accessor :id, :formatted_address, :location, :address_components

  def persisted?
    !@id.nil?
  end

  def initialize(params)
    @id = params[:_id].to_s

    @address_components = []
    if !params[:address_components].nil?
      address_components = params[:address_components]
      address_components.each { |a| @address_components << AddressComponent.new(a) }
    end
    

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

  def self.create_indexes
    Place.collection.indexes.
      create_one({'geometry.geolocation': Mongo::Index::GEO2DSPHERE})
  end

  def self.remove_indexes
    Place.collection.indexes.drop_one('geometry.geolocation_2dsphere')
  end

  def self.near(p, max_meters=nil)
    max_meters = max_meters.to_i if !max_meters.nil?

    if !max_meters.nil?
      Place.collection.find(
        {'geometry.geolocation': 
         {'$near': p.to_hash, :$maxDistance => max_meters}})
    else
      Place.collection.find(
        {'geometry.geolocation': 
         {'$near': p.to_hash}})
    end
  end

  def near(max_meters=nil)
    max_meters = max_meters.to_i if !max_meters.nil?

    near_points = []
    if !max_meters.nil?
      Place.collection.find(
        {'geometry.geolocation': 
         {'$near': @location.to_hash, :$maxDistance => max_meters}
        }
      ).each { |p| 
        near_points << Place.new(p)
      }
    else
      Place.collection.find(
        {'geometry.geolocation': 
         {'$near': @location.to_hash}}
      ).each { |p|
        near_points << Place.new(p)
      }
    end

    return near_points
  end

  def photos(offset=0, limit=0)
    self.class.mongo_client.database.fs.find(
      "metadata.place": BSON::ObjectId.from_string(@id)
    ).map { |photo|
      Photo.new(photo)
    }
  end 

end
