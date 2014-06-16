class Election
  include ActiveModel::Model

  attr_accessor :title, :description, :process_image, :positions
  attr_reader :id, :created, :modified, :status

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @process_image = attributes[:process_image]
    @positions = attributes[:positions]
    @status = attributes[:status]
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

  def update_attributes(attributes={})
    @title = attributes[:title]
    @description = attributes[:description]
    @process_image = attributes[:process_image]
    @positions = attributes[:positions]
    @status = attributes[:status]
    if self.valid?
      Rails.logger.debug "The election is valid!"
      directory = "app/assets/images/elections"
      # create the file path
      path = File.join(directory, @id+File.extname(@process_image.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@process_image.read) }
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
    Election.new(
      id: id, 
      tittle: "Test Title", 
      description: "Test Description", 
      process_image: "chuta", 
      positions: Array(
        {:id=>1, :title => "President", :description => "This is the president"},
        {:id=>2, :title => "Vicepresident", :description => "This is the vicepresident"},
        {:id=>3, :title => "Secretary", :description => "This is the secretary"},
        {:id=>4, :title => "Treasurer", :description => "This is the treasurer"}
        ))
  end

end