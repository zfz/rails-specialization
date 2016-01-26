require 'json'

class Place
  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params)
    @id = params[:_id].to_s

    @address_components = []
    address_components = params[:address_components]
    address_components.each { |a| @address_components << AddressComponent.new(a) }

    @formatted_address = params[:formatted_address]
    @location = params[:geometry][:geolocation]
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

end
