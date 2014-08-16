class Photo
  include ActiveModel::Model

  attr_accessor :title, :description, :path, :alter_text
  attr_reader :id

  #validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  #validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :path, :presence => { :message => ApplicationHelper.validation_error(:path, :presence, nil) }
  #validates :alter_text, :presence => { :message => ApplicationHelper.validation_error(:alter_text, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @path = attributes[:path]
    @alter_text = attributes[:alter_text]
  end

  def save  
    if self.valid?
      Rails.logger.debug "The photo is valid!"
      directory = "app/assets/images/photos"
      #get ID from the Database to create the image file
      @id = "id"
      # create the file path
      path = File.join(directory, @id+File.extname(@path.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@path.read) }
      true
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

  def update_attributes(attributes={})
    @title = attributes[:title]
    @description = attributes[:description]
    @path = attributes[:path]
    @alter_text = attributes[:alter_text]
    if self.valid?
      Rails.logger.debug "The photo is valid!"
      directory = "app/assets/images/photos"
      # create the file path
      path = File.join(directory, @id+File.extname(@path.original_filename))
      # write the file
      File.open(path, "wb") { |f| f.write(@path.read) }
      true#call to the update method of the DB
    else
      Rails.logger.debug self.errors.full_messages
      false
    end
  end

  public
  def destroy
  end

  def self.all
    [ Photo.new(id: 1, title: "Barong", description: "Bali protector god", path:"1.png", alter_text:"Barong"),
      Photo.new(id: 2, title: "Dragon", description: "Tribal Dragon", path:"2.jpg", alter_text:"Dragon"),
      Photo.new(id: 3, title: "Vagacato", description: "Cat dressed as cow", path:"3.jpg", alter_text:"Vagacato"),
      Photo.new(id: 4, title: "Dark Side", description: "Dark Side of the Moon", path:"4.jpg", alter_text:"Dark Side"),
      Photo.new(id: 5, title: "Triforce", description: "Legend of Zelda Triforce", path:"5.png", alter_text:"Triforce")
    ]
    end

  def self.find(id)
  @photo =  Photo.new(
      id: id, 
      title: "Test Title", 
      description: "Test Description", 
      path: "chuta", 
      alter_text: "Test Alter Text"
  )
  end

end