class Poll
  include ActiveModel::Model

  attr_accessor :question, :date, :options, :picture
  attr_reader :id, :created, :modified

  validates :question, :presence => { :message => ApplicationHelper.validation_error(:question, :presence, nil) }
  validates :options, :presence => { :message => ApplicationHelper.validation_error(:options, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :picture, :presence => { :message => ApplicationHelper.validation_error(:picture, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @question = attributes[:question]
    @date = attributes[:date]
    @options = attributes[:options]
    @picture = attributes[:picture]
  end

  def self.all
      [Poll.new(id: 1, question: "Who will win the FIFA World Cup?", date:"2014/05/31"), 
      Poll.new(id: 2, question: "Who will win Wimbledon?", date:"2014/06/01"),
      Poll.new(id: 3, question: "What was first, the hen or the egg?", date:"2014/06/02")]
  end

  def save
    if self.valid?
      Rails.logger.debug "The poll question is valid!"
      directory = "app/assets/images/polls"
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

end