class Position
  include ActiveModel::Model

  attr_accessor :name, :description, :election_id
  attr_reader :id

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil)}
  validates :election_id, :presence => { :message => ApplicationHelper.validation_error(:election, :presence, nil) }
  validates :id, :presence =>{ :message => ApplicationHelper.validation_error(:id, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Position object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:question]
    @description = attributes[:start_date]
    @election_id = attributes[:answers]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Position
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created position object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)
    Rails.logger.debug "Call to position.save"
    if self.valid? #Validate if the Poll object is valid
      Rails.logger.debug "The position is valid!"
      #Create a raw position object
      position_req = { 'name'=>self.name,
                'description'=> self.duration,
                'electionId'=> self.election_id
                }
      reqUrl = "/api/position/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,position_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        position = Position.rest_to_position(rest_response.body) #Turn the response object to a Position object
        return true, position #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to delete a Position
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to position.delete"
    reqUrl = "/api/position/#{self.id}" #Set the request url
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password']) #Make the DELETE request to the server with the required parameters
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
      return true, rest_response #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to update a Position
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated position object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {}, user)
    Rails.logger.debug "Call to position.update_attributes"
    if self.valid? #Validate if the Position object is valid
      Rails.logger.debug "The position is valid!"
      #Create a raw position object
      position_req = { 'name'=>attributes[:name],
                'description'=>attributes[:description],
                'election_id'=> self.election_id
                }     
      reqUrl = "/api/position/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,position_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        position = Position.rest_to_position(rest_response.body)
        return true, position #Return success
      else
        return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve a position by its id
  Param 1: position id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Position object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to position.find"
    reqUrl = "/api/position/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      position = Position.rest_to_position(rest_response.body) #Turn the response object to a Position object
      return true, position #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the positions by its election id
  Param 1: logged user object
  Param 2: id of the election that owns the positions
  Param 3: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the positions objects, 
                        3.total number of positions, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, election_id, page)
    Rails.logger.debug "Call to positions.all"
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/positions/#{election_id}?page=#{page}&pageSize=10" #Build the request url
   
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_positions_list = JSON.parse(rest_response.body) #Get the positions info from the response and normalize it to an array to handle it
      total_positions = raw_positions_list['totalElements'] #Retrieve the total positions number for pagination
      total_pages = raw_positions_list['totalPages'] #Retrieve the total number of pages for pagination
      positionsList = Array.new #Initialize an empty array for the positions
      for raw_position in raw_positions_list['foundObjects'] #For each position received from the server
        position = Positon.rest_to_position(raw_position.to_json) #Turn a position to json format
        positionsList << positon #Add it to the positions array
      end
      return true, positionsList, total_positions, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Position object
  Param 1: Raw object
  Return 1: Transformed Position object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_position(rest_body)
    raw_position = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      position = Position.new(
        id: raw_position["positionId"], 
        name: raw_position["name"], 
        description: raw_position["description"],
        election_id: raw_position["electionId"])  
      return position #Return the transformed object
  end

end