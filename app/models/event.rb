class event
include ActiveModel::Model

  attr_accessor :name, :date, :location, :description, :picture, :volunteers
  attr_reader :id, :created, :modified

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :location, :presence => { :message => ApplicationHelper.validation_error(:location, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @date = attributes[:date]
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
      path = File.join(directory, @id+File.extname(@process_image.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@process_image.read) }
      true
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

#  def update_attributes(attributes={})
#    @name = attributes[:name]
#    @description = attributes[:description]
#    @process_image = attributes[:process_image]
#    @positions = attributes[:positions]
#    @status = attributes[:status]
#    if self.valid?
#      Rails.logger.debug "The election is valid!"
#      directory = "app/assets/images/elections"
#      # create the file path
#      path = File.join(directory, @id+File.extname(@process_image.original_filename))
#      # write the file
#      File.open(path, "wb") { |f| f.write(@process_image.read) }
#      true#call to the update method of the DB
#    else
#      Rails.logger.debug self.errors.full_messages
#      false
#    end
#  end

#  public
#  def destroy
#  end

  def self.find(id)
    Event.new(
      id: id, 
      tittle: "Test Title", 
      description: "Test Description", 
      process_image: "chuta", 
      positions: Array(
        {:id=>1, :name => "President", :description => "This is the president"},
        {:id=>2, :name => "Vicepresident", :description => "This is the vicepresident"},
        {:id=>3, :name => "Secretary", :description => "This is the secretary"},
        {:id=>4, :name => "Treasurer", :description => "This is the treasurer"}
        ))
  end

  def self.all
    [{id: 1, name: "BBQ1", date: "2014/01/02", location: "Melbourne", description: "Delicious free meal for out followers 1", picture: "1.jpg", volunteers:[{position_title: "Helper 11", description: "The first one that helps11"},{position_title: "Helper 12", description: "The second one that helps12"}]},
     {id: 2, name: "BBQ2", date: "2014/02/03", location: "Sydney", description: "Delicious free meal for out followers 2", picture: "2.jpg", volunteers:[{position_title: "Helper 21", description: "The first one that helps21"},{position_title: "Helper 22", description: "The second one that helps22"}]},
     {id: 3, name: "BBQ3", date: "2014/03/04", location: "London", description: "Delicious free meal for out followers 3", picture: "3.jpg", volunteers:[{position_title: "Helper 31", description: "The first one that helps31"},{position_title: "Helper 32", description: "The second one that helps32"}]}
    ]
  end
end