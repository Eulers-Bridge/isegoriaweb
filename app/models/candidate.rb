class Candidate
  include ActiveModel::Model

  attr_accessor :information, :policy_statement, :photos, :first_name, :last_name, :user_id, :position_id, :ticket_id
  attr_reader :id

  validates :information, :presence => { :message => ApplicationHelper.validation_error(:information, :presence, nil) }
  validates :policy_statement, :presence => { :message => ApplicationHelper.validation_error(:policy_statement, :presence, nil)}
  validates :user_id, :presence => { :message => ApplicationHelper.validation_error(:user, :presence, nil)}
  validates :position_id, :presence => { :message => ApplicationHelper.validation_error(:position, :presence, nil)}
  validates :ticket_id, :presence => { :message => ApplicationHelper.validation_error(:ticket, :presence, nil) }
  validates :id, :presence =>{ :message => ApplicationHelper.validation_error(:id, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Candidate object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @information = attributes[:information]
    @policy_statement = attributes[:policy_statement]
    @photos = attributes[:photos]
    @user_id = attributes[:user_id]
    @first_name = attributes [:first_name]
    @last_name = attributes [:last_name]
    @position_id = attributes[:position_id]
    @ticket_id = attributes[:ticket_id]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Candidate
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created candidate object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)
    Rails.logger.debug "Call to candidate.save"
    if self.valid? #Validate if the Candidate object is valid
      Rails.logger.debug "The candidate is valid!"
      #Create a raw candidate object
      candidate_req = { 'information'=>self.information,
                'policyStatement'=> self.policy_statement,
                'photos' => [],
                'userId'=> self.user_id,
                'positionId' => self.position_id,
                'ticketId' => self.ticket_id
                }
      reqUrl = "/api/candidate/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,candidate_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        candidate = Candidate.rest_to_candidate(rest_response.body) #Turn the response object to a Candidate object
        return true, candidate #Return success
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
  Function to delete a Candidate
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to candidate.delete"
    reqUrl = "/api/candidate/#{self.id}" #Set the request url
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
  Function to update a Candidate
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated candidate object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {}, user)
    Rails.logger.debug "Call to candidate.update_attributes"
    if self.valid? #Validate if the Candidate object is valid
      Rails.logger.debug "The candidate is valid!"
      #Create a raw candidate object
      candidate_req = { 'information'=>attributes[:information],
                'policyStatement'=> attributes[:policy_statement],
                'photos' => [],
                'userId'=> attributes[:user_id],
                'positionId' => attributes[:position_id],
                'ticketId' => attributes[:ticket_id]
                }   
      reqUrl = "/api/candidate/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,position_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        candidate = Candidate.rest_to_candidate(rest_response.body)
        return true, candidate #Return success
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
  Function to retrieve a candidate by its id
  Param 1: candidate id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Candidate object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to candidate.find"
    reqUrl = "/api/candidate/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      candidate = Candidate.rest_to_candidate(rest_response.body) #Turn the response object to a Candidate object
      return true, candidate #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the candidates by its ticket id
  Param 1: logged user object
  Param 2: id of the ticket that owns the candidates
  Param 3: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the candidates objects, 
                        3.total number of candidate, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, ticket_id, page)
    Rails.logger.debug "Call to candidates.all"
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/candidates/#{ticket_id}?page=#{page}&pageSize=10" #Build the request url
   
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_candidates_list = JSON.parse(rest_response.body) #Get the candidate info from the response and normalize it to an array to handle it
      total_candidates = raw_candidates_list['totalElements'] #Retrieve the total candidates number for pagination
      total_pages = raw_candidates_list['totalPages'] #Retrieve the total number of pages for pagination
      candidatesList = Array.new #Initialize an empty array for the candidates
      for raw_candidate in raw_candidates_list['foundObjects'] #For each candidate received from the server
        candidate = Candidate.rest_to_candidate(raw_candidate.to_json) #Turn a candidate to json format
        candidatesList << candidate #Add it to the candidates array
      end
      return true, candidatesList, total_positions, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Candidate object
  Param 1: Raw object
  Return 1: Transformed Candidate object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_candidate(rest_body)
    raw_candidate = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      candidate = Candidate.new(
        id: raw_candidate["candidateId"], 
        information: raw_candidate["information"], 
        policy_statement: raw_candidate["policyStatement"],
        photos: raw_candidate["photos"],
        user_id: raw_candidate["userId"],
        first_name: raw_candidate["givenName"],
        last_name: raw_candidate["familyName"],
        position_id: raw_candidate["positionId"],
        ticket_id: raw_candidate["ticketId"])  
      return candidate #Return the transformed object
  end

end