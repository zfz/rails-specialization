class Point
  attr_accessor :longitude, :latitude

  def initialize(lng, lat)
    @longitude = lng
    @latitude = lat
  end

  #creates a DB-form of the instance
  def mongoize
    {:type=>'Point', :coordinates=>[@longitude,@latitude]}
  end
  
  def self.demongoize(object)
    case object
    when Hash then 
      Point.new(object[:coordinates][0], object[:coordinates][1])
    when nil
      nil
    end
  end

  #takes in all forms of the object and produces a DB-friendly form
  def self.mongoize(object) 
    case object
    when Point then object.mongoize
    when Hash then 
      if object[:type] #in GeoJSON Point format
          Point.new(object[:coordinates][0], object[:coordinates][1]).mongoize
      else       #in legacy format
          Point.new(object[:lng], object[:lat]).mongoize
      end
    else object
    end
  end

  #used by criteria to convert object to DB-friendly form
  def self.evolve(object)
    case object
    when Point then object.mongoize
    else object
    end
  end

end
