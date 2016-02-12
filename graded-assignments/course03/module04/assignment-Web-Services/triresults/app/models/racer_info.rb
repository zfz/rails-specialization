class RacerInfo
  include Mongoid::Document
  
  field :fn, as: :first_name, type: String
  field :ln, as: :last_name, type: String
  field :yr, as: :birth_year, type: Integer
  field :g, as: :gender, type: String
  field :res, as: :residence, type: Address
  field :racer_id, as: :_id
  field :_id, default:->{ racer_id }

  embedded_in :parent, polymorphic: true
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :gender
  validates_presence_of :birth_year
  validates :gender, :inclusion=> { :in => ['M', 'F'] }
  validates :birth_year, :numericality => { :less_than => Date.current.year }

  #def city
  #  self.residence ? self.residence.city : nil 
  #end

  #def city= name
  #  object = self.residence ||= Address.new 
  #  object.city = name 
  #  self.residence = object
  #end

  ["city", "state"].each do |action| 
    define_method("#{action}") do
      self.residence ? self.residence.send("#{action}") : nil 
    end
    define_method("#{action}=") do |name| 
      object=self.residence ||= Address.new 
      object.send("#{action}=", name) 
      self.residence=object
    end 
  end

end
