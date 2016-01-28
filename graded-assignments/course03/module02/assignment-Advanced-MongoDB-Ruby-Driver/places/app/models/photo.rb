class Photo
  attr_accessor :id, :location
  attr_writer :contents

  def initialize(params=nil)
    @id = params[:_id].to_s if !params.nil? && !params[:_id].nil?
    @location = Point.new(params[:metadata][:location]) if !params.nil? && !params[:metadata].nil?
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def persisted?
    !@id.nil?
  end

  def save
    if !persisted?
      gps = EXIFR::JPEG.new(@contents).gps
      location=Point.new(:lng=>gps.longitude, :lat=>gps.latitude)
      @contents.rewind

      description={}
      description[:metadata] = {:location => location.to_hash}
      #description[:contentType] = "image/jpeg" #don't know why not work
      description[:content_type] = "image/jpeg"
      @location = Point.new(location.to_hash)
      grid_file = Mongo::Grid::File.new(@contents.read, description)
      @id = self.class.mongo_client.database.fs.insert_one(grid_file).to_s
    else
      u = {:location => @location.to_hash}
      self.class.mongo_client.database.fs.find('_id':BSON::ObjectId.from_string(@id)).update_one(:$set => {"metadata": u})
    end
  end

  def self.all(offset=0, limit=0)
    mongo_client.database.fs.find.skip(offset).limit(limit).map { |doc|
      Photo.new(doc)
    }
  end

  def self.find(id)
    doc = mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(id)).first
    doc.nil? ? nil : photo = Photo.new(doc)
  end

  def contents
    f = self.class.mongo_client.database.fs.find_one(:_id=>BSON::ObjectId.from_string(@id))
    if f 
      buffer = ""
      f.chunks.reduce([]) do |x,chunk| 
          buffer << chunk.data.data 
      end
      return buffer
    end 
  end

  def destroy
    self.class.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(@id)).delete_one
  end

  def find_nearest_place_id(max_meters)
    Place.collection.find(
      {'geometry.geolocation': 
       {'$near': @location.to_hash}
      }).limit(1).projection({:_id=>1}).first[:_id]
  end

end
