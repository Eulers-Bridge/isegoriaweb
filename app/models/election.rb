class Election
  include ActiveModel::Model

  attr_accessor :title, :description, :process_image, :positions, :_start, :_end, :startVoting, :endVoting
  attr_reader :id, :status

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @process_image = attributes[:process_image]
    @positions = attributes[:positions]
    @status = attributes[:status]
    @_start = attributes[:_start]
    @_end = attributes[:_end]
    @startVoting = attributes[:startVoting]
    @endVoting = attributes[:endVoting]
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
    reqUrl = "/api/election/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl)
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_election = JSON.parse(@rest_response.body)
      @election = Election.new(
        id: @raw_election["electionId"], 
        title: @raw_election["title"], 
        description: "Not Implemented - Test Description", 
        process_image: "election_1.jpg", 
        positions: [
        {:id=>1, :title => "President", :description => "This is the president"},
        {:id=>2, :title => "Vicepresident", :description => "This is the vicepresident"},
        {:id=>3, :title => "Secretary", :description => "This is the secretary"},
        {:id=>4, :title => "Treasurer", :description => "This is the treasurer"}],
        _start: @raw_election["start"],
        _end: @raw_election["end"],
        startVoting: @raw_election["startVoting"],
        endVoting: @raw_election["endVoting"],
        )
      return true, @election
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

end