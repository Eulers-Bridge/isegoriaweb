class Event
include ActiveModel::Model

  attr_accessor :name, :date, :location, :description, :picture, :volunteers
  attr_reader :id, :creator

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :location, :presence => { :message => ApplicationHelper.validation_error(:location, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :picture, :presence => { :message => ApplicationHelper.validation_error(:picture, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @date = attributes[:date]
    @creator = 'test user'
    @location = attributes[:location]
    @description = attributes[:description]
    @picture = attributes[:picture]
    @volunteers = attributes[:volunteers]
  end

  def save  
   if self.valid?
      Rails.logger.debug "The election is valid!"
      directory = "app/assets/images/elections"
      #get ID from the Database to create the image file
      @id = "id"
      # create the file path
      path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@picture.read) }
      true
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

  def update_attributes(attributes={})
    @name = attributes[:name]
    @date = attributes[:date]
    @location = attributes[:location]
    @description = attributes[:description]
    @picture = attributes[:picture]
    @volunteers = attributes[:vounteers]
    if self.valid?
      Rails.logger.debug "The event is valid!"
      directory = "app/assets/images/events"
      # create the file path
      path = File.join(directory, @id+File.extname(@picture.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@picture.read) }
      true#call to the update method of the DB
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

  public
  def destroy
  end

  def self.find(id)
    require 'json'
    Event.new(
      id: id, 
      name: "BBQ1", 
      date: "2014/01/02", 
      location: Location.new(name:'Parque el Ejido',latitude: -0.21,longitude: -78.5), 
      description: "Delicious free meal for out followers 1", 
      picture: "1.jpg", 
      volunteers:[Volunteer.new(position_title: "Helper 11", description: "The first one that helps11"),Volunteer.new(position_title: "Helper 12", description: "The second one that helps12")]
      )
  end

  def self.all
    [
     Event.new(id: 1, name: "BBQ1", date: "2014/01/02", location: Location.new(name:'Parque el Ejido',latitude: -0.21,longitude: -78.5), description: "Delicious free meal for out followers 1", picture: "1.jpg", volunteers:[Volunteer.new(position_title: "Helper 11", description: "The first one that helps11"),Volunteer.new(position_title: "Helper 12", description: "The second one that helps12")]),
     Event.new(id: 2, name: "BBQ2", date: "2014/02/03", location: Location.new(name:'Central Park',latitude: 40.78,longitude: -73.9667), description: "Delicious free meal for out followers 2", picture: "2.png", volunteers:[Volunteer.new(position_title: "Helper 21", description: "The first one that helps21"),Volunteer.new(position_title: "Helper 22", description: "The second one that helps22")]),
     Event.new(id: 3, name: "BBQ3", date: "2014/03/04", location: Location.new(name:'London Eye',latitude: 51.5,longitude: -0.1197), description: "Delicious free meal for out followers 3", picture: "3.jpg", volunteers:[Volunteer.new(position_title: "Helper 31", description: "The first one that helps31"),Volunteer.new(position_title: "Helper 32", description: "The second one that helps32")])
    ]
  end
end