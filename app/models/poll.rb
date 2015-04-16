class Poll
  include ActiveModel::Model

  attr_accessor :question, :start_date, :answers, :duration, :owner_id, :creator_id
  attr_reader :id

  validates :question, :presence => { :message => ApplicationHelper.validation_error(:question, :presence, nil) }
  #validates :answers, :presence => { :message => ApplicationHelper.validation_error(:answers, :presence, nil) }
  validates :answers, :length => { minimum: 1, :message => ApplicationHelper.validation_error(:answers, :presence, nil)}
  validates :start_date, :presence => { :message => ApplicationHelper.validation_error(:start_date, :presence, nil) }
  validates :duration, :presence =>{ :message => ApplicationHelper.validation_error(:duration, :presence, nil) }
  validates :owner_id, :presence =>{ :message => ApplicationHelper.validation_error(:owner_id, :presence, nil) }
  validates :creator_id, :presence =>{ :message => ApplicationHelper.validation_error(:creator_id, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Poll object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @question = attributes[:question]
    @start_date = attributes[:start_date]
    @answers = attributes[:answers]
    @duration = attributes[:duration]
    @owner_id = attributes[:owner_id]
    @creator_id = attributes[:creator_id]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Poll
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created poll object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)
    Rails.logger.debug "Call to polls.save"
    self.answers=Util.arraystring_to_csv(self.answers)
    if self.valid? #Validate if the Poll object is valid
      Rails.logger.debug "The poll question is valid!"
      #Create a raw poll object
      poll_req = { 'question'=>self.question,
                'answers'=>Util.arraystring_to_csv(self.answers),#Turn the answers array in string form to a comma separated string
                'start'=> Util.date_to_epoch(self.start_date), #Turn the start_date to epoch
                'duration'=> self.duration.to_i*60000, #Turn minutes to milliseconds
                'ownerId'=> self.owner_id,
                'creatorId'=> self.creator_id
                }
      reqUrl = "/api/poll/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,poll_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        poll = Poll.rest_to_poll(rest_response.body) #Turn the response object to a Poll object
        return true, poll #Return success
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
  Function to delete a Poll
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to poll.delete"
    reqUrl = "/api/poll/#{self.id}" #Set the request url
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
  Function to update a Poll
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated poll object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {}, user)
    Rails.logger.debug "Call to poll.update_attributes"
    self.answers=Util.arraystring_to_csv(attributes[:answers])
    if self.valid? #Validate if the Poll object is valid
      Rails.logger.debug "The poll is valid!"
      #Create a raw poll object
      poll_req = { 'question'=>attributes[:question],
                'answers'=>Util.arraystring_to_csv(attributes[:answers]),#Turn the answers array in string form to a comma separated string
                'start'=> Util.date_to_epoch(attributes[:start_date]), #Turn the start_date to epoch
                'duration'=> attributes[:duration].to_i*60000, #Turn minutes to milliseconds
                'ownerId'=> self.owner_id,
                'creatorId'=> self.creator_id,
                }     
      reqUrl = "/api/poll/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,poll_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        poll = Poll.rest_to_poll(rest_response.body)
        return true, poll #Return success
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
  Function to retrieve a poll by its id
  Param 1: poll id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Poll object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to poll.find"
    reqUrl = "/api/poll/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      poll = Poll.rest_to_poll(rest_response.body) #Turn the response object to a Poll object
      return true, poll #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the polls by its owner id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the polls objects, 
                        3.total number of polls, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to polls.all"
    owner_id = user['institutionId'] #Retrieve the owner id from the logged user
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/polls/#{owner_id}?page=#{page}&pageSize=10" #Build the request url
   
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_polls_list = JSON.parse(rest_response.body) #Get the polls info from the response and normalize it to an array to handle it
      total_polls = raw_polls_list['totalElements'] #Retrieve the total polls number for pagination
      total_pages = raw_polls_list['totalPages'] #Retrieve the total number of pages for pagination
      pollsList = Array.new #Initialize an empty array for the polls
      for raw_poll in raw_polls_list['foundObjects'] #For each poll received from the server
        poll = Poll.rest_to_poll(raw_poll.to_json) #Turn a poll to json format
        pollsList << poll #Add it to the polls array
      end
      return true, pollsList, total_polls, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Poll object
  Param 1: Raw object
  Return 1: Transformed Poll object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_poll(rest_body)
    raw_poll = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      poll = Poll.new(
        id: raw_poll["nodeId"], 
        question: raw_poll["question"], 
        #answers: raw_poll["answers"],
        answers: raw_poll["answers"].split(','), 
        start_date: Util.epoch_to_date(raw_poll["start"]), #Turn the epoch time to a string start_date, format defined by the locale parameter
        duration: raw_poll["duration"]/60000, #Turn milliseconds to minutes
        owner_id: raw_poll["ownerId"],
        creator_id: raw_poll["creatorId"])  
      return poll #Return the transformed object
  end

end