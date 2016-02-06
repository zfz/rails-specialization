class Address
  attr_accessor :city, :state, :location

  def initialize(city=nil, state=nil, loc=nil)
    @city = city
    @state = state
    if loc.nil?
      @location = Point.new(0.0, 0.0)
    else
      @location = Point.new(loc[:coordinates][0], loc[:coordinates][1])
    end
  end

  #creates a DB-form of the instance
  def mongoize
    {
      :city => @city, :state => @state, 
      :loc => {
        :type => 'Point', :coordinates => [
          @location.longitude, @location.latitude
        ]
      }
    }
  end
  
  def self.demongoize(object)
    case object
    when Hash then 
      Address.new(object[:city], object[:state], object[:loc])
    when nil 
      nil 
    end 
  end

  #takes in all forms of the object and produces a DB-friendly form
  def self.mongoize(object) 
    case object
    when Address then 
      object.mongoize
    when Hash then 
      #if object[:type] #in GeoJSON Point format
      Address.new(object[:city], object[:state], object[:loc]).mongoize
      #else       #in legacy format
      #    Point.new(object[:lng], object[:lat]).mongoize
      #end
    else object
    end
  end

  #used by criteria to convert object to DB-friendly form
  def self.evolve(object)
    case object
    when Address then object.mongoize
    else object
    end 
  end 

end
