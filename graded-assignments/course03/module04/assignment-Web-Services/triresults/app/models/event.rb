class Event
  include Mongoid::Document

  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String

  embedded_in :parent, polymorphic: true, touch: true
  validates :order, presence: true
  validates :name, presence: true

  def meters
    if self.u == 'meters'
      self.distance
    elsif self.u == 'miles'
      self.distance * 1609.34
    elsif self.u == 'kilometers'
      self.distance * 1000
    elsif self.u == 'yards'
      self.distance * 0.9144
    end
  end

  def miles
    if self.u == 'meters'
      self.distance * 0.000621371
    elsif self.u == 'miles'
      self.distance
    elsif self.u == 'kilometers'
      self.distance * 0.621371
    elsif self.u == 'yards'
      self.distance * 0.000568182
    end
  end

end
