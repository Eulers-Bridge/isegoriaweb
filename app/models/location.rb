class Location

  attr_accessor :name, :latitude, :longitude, :country, :state, :city,:street, :number,:postal_code

  def initialize (attributes = {})
    @name = attributes[:name]
    @latitude = attributes[:latitude]
    @longitude = attributes[:longitude]
  end
end