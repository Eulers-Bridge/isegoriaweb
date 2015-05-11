class Ticket
  include ActiveModel::Model

  attr_accessor :name, :acronym, :photos, :information, :color, :candidates, :election_id, :number_of_supporters, :picture
  attr_reader :id

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :acronym, :presence => { :message => ApplicationHelper.validation_error(:acronym, :presence, nil)}
  validates :information, :presence => { :message => ApplicationHelper.validation_error(:information, :presence, nil)}
  validates :color, :presence => { :message => ApplicationHelper.validation_error(:color, :presence, nil)}
  validates :election_id, :presence => { :message => ApplicationHelper.validation_error(:election, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Ticket object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @acronym = attributes[:acronym]
    @photos = attributes[:photos]
    @information = attributes[:information]
    @color = attributes [:color]
    @candidates = attributes [:candidates]
    @election_id = attributes[:election_id]
    @number_of_supporters = attributes[:number_of_supporters]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Ticket
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created ticket object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)
    Rails.logger.debug "Call to ticket.save"
    if self.valid? #Validate if the Ticket object is valid
      Rails.logger.debug "The ticket is valid!"
      #Create a raw ticket object
      ticket_req = { 'name'=>self.name,
                'logo'=> self.acronym,
                'photos' => [],
                'information'=> self.information,
                'colour' => self.color,
                'candidateNames' => [],
                'electionId'=> self.election_id,
                'numberOfSupporters' =>self.number_of_supporters
                }
      reqUrl = "/api/ticket/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,ticket_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        ticket = Ticket.rest_to_ticket(rest_response.body) #Turn the response object to a Ticket object
        return true, ticket #Return success
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
  Function to delete a Ticket
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to ticket.delete"
    reqUrl = "/api/ticket/#{self.id}" #Set the request url
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
  Function to update a Ticket
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated ticket object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {}, user)
    Rails.logger.debug "Call to ticket.update_attributes"
    if self.valid? #Validate if the Ticket object is valid
      Rails.logger.debug "The ticket is valid!"
      #Create a raw ticket object
      ticket_req = { 'name'=>attributes[:name],
                'logo'=> attributes[:acronym],
                'photos' => [],
                'information'=> attributes[:information],
                'colour' => attributes[:color],
                'candidateNames' => [],
                'electionId'=> self.election_id,
                'numberOfSupporters' =>self.number_of_supporters
                }    
      reqUrl = "/api/ticket/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,ticket_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        ticket = Ticket.rest_to_ticket(rest_response.body)
        return true, ticket #Return success
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
  Function to retrieve a ticket by its id
  Param 1: ticket id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Ticket object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to ticket.find"
    reqUrl = "/api/ticket/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      ticket = Ticket.rest_to_ticket(rest_response.body) #Turn the response object to a Ticket object
      return true, ticket #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the tickets by its election id
  Param 1: logged user object
  Param 2: id of the election that owns the tickets
  Param 3: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the tickets objects, 
                        3.total number of tickets, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, election_id, page)
    Rails.logger.debug "Call to tickets.all"
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/tickets/#{election_id}?page=#{page}&pageSize=10" #Build the request url
   
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_tickets_list = JSON.parse(rest_response.body) #Get the ticket info from the response and normalize it to an array to handle it
      total_tickets = raw_tickets_list['totalElements'] #Retrieve the total tickets number for pagination
      total_pages = raw_tickets_list['totalPages'] #Retrieve the total number of pages for pagination
      ticketsList = Array.new #Initialize an empty array for the tickets
      for raw_ticket in raw_tickets_list['foundObjects'] #For each ticket received from the server
        ticket = Ticket.rest_to_ticket(raw_ticket.to_json) #Turn a ticket to json format
        ticketsList << ticket #Add it to the positions array
      end
      return true, ticketsList, total_tickets, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Ticket object
  Param 1: Raw object
  Return 1: Transformed Ticket object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_ticket(rest_body)
    raw_ticket = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      ticket = Ticket.new(
        id: raw_ticket["ticketId"], 
        name: raw_ticket["name"], 
        acronym: raw_ticket["logo"],
        photos: raw_ticket["photos"],
        information: raw_ticket["information"],
        color: raw_ticket["colour"],
        candidates: raw_ticket["candidateNames"],
        election_id: raw_ticket["electionId"],
        number_of_supporters: raw_ticket["numberOfSupporters"])  
      return ticket #Return the transformed object
  end

end