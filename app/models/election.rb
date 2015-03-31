class Election
  include ActiveModel::Model

  attr_accessor :title, :start_date, :end_date, :start_voting_date, :end_voting_date, :introduction, :process, :institution_id
  attr_reader :id

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :start_date, :presence => { :message => ApplicationHelper.validation_error(:start_date, :presence, nil) }
  validates :end_date, :presence => { :message => ApplicationHelper.validation_error(:end_date, :presence, nil) }
  validates :start_voting_date, :presence => { :message => ApplicationHelper.validation_error(:start_voting_date, :presence, nil) }
  validates :end_voting_date, :presence => { :message => ApplicationHelper.validation_error(:end_voting_date, :presence, nil) }
  validates :institution_id, :presence => { :message => ApplicationHelper.validation_error(:institution_id, :presence, nil) }
  validates :introduction, :presence => { :message => ApplicationHelper.validation_error(:introduction, :presence, nil) }
  validates :process, :presence => { :message => ApplicationHelper.validation_error(:process, :presence, nil) }


=begin
--------------------------------------------------------------------------------------------------------------------
  Election object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @start_date = attributes[:start_date]
    @end_date = attributes[:end_date]
    @start_voting_date = attributes[:start_voting_date]
    @end_voting_date = attributes[:end_voting_date]
    @institution_id = attributes[:institution_id]
    @introduction = attributes[:introduction]
    @process = attributes[:process]
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Election
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)  
    Rails.logger.debug "Call to election.save"
    if self.valid? #Validate if the Election object is valid
      Rails.logger.debug "The election is valid!"
      #Create a raw election object
      election_req = { 'title'=>self.title,
                'start'=> Util.date_to_epoch(self.start_date), #Turn the start_date to epoch
                'end'=> Util.date_to_epoch(self.end_date), #Turn the end_date to epoch
                'startVoting'=> Util.date_to_epoch(self.start_voting_date), #Turn the start_voting_date to epoch,
                'endVoting'=> Util.date_to_epoch(self.end_voting_date), #Turn the end_voting_date to epoch,
                'institutionId' =>self.institution_id,
                'introduction' =>self.introduction,
                'process' =>self.process
                }
      reqUrl = "/api/election/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,election_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        election = Election.rest_to_election(rest_response.body) #Turn the response object to a Election object
        return true, election #Return success
      else
        return false, "#{rest_response.code} #{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to delete an Election
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to election.delete"
    reqUrl = "/api/election/#{self.id}" #Set the request url
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password']) #Make the DELETE request to the server with the required parameters
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
      return true, rest_response #Return success
    else
      return false, "#{rest_response.code} #{rest_response.message}" #Return error
    end
  end 


=begin
--------------------------------------------------------------------------------------------------------------------
  Function to update an Election
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {}, user)
    Rails.logger.debug "Call to election.update_attributes"
    if self.valid? #Validate if the Election object is valid
      Rails.logger.debug "The election is valid!"
      #Create a raw election object
      election_req = { 'title'=>attributes[:title],
                'start'=>Util.date_to_epoch(attributes[:start_date]),#Turn the start_date to epoch
                'end'=> Util.date_to_epoch(attributes[:end_date]), #Turn the end_date to epoch
                'startVoting'=> Util.date_to_epoch(attributes[:start_voting_date]), #Turn the start_voting_date to epoch
                'endVoting'=> Util.date_to_epoch(attributes[:end_voting_date]), #Turn the end_voting_date to epoch
                'institutionId'=> self.institution_id,
                'introduction'=> self.introduction,
                'process'=> self.process
                }     
      reqUrl = "/api/election/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,election_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        election = Election.rest_to_election(rest_response.body)
        return true, election #Return success
      else
        return false, "#{rest_response.code} #{rest_response.message}" #Return error
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages #Return invalid object error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve a elections by its id
  Param 1: election id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to election.find"
    reqUrl = "/api/election/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      election = Election.rest_to_election(rest_response.body) #Turn the response object to an Election object
      return true, election #Return success
    else
      return false, "#{rest_response.code} #{rest_response.message}" #Return error
    end

  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the elections by its institution id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the election objects, 
                        3.total number of elections, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to elections.all"
    institution_id = user['institutionId'] #Retrieve the institution id from the logged user
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/elections/#{institution_id}?page=#{page}&pageSize=10" #Build the request url
   
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_elections_list = JSON.parse(rest_response.body) #Get the elections info from the response and normalize it to JSON to handle it
      #total_elections = raw_elections_list['totalElections'] #Retrieve the total elections number for pagination
      #total_pages = raw_elections_list['totalPages'] #Retrieve the total number of pages for pagination
      #electionsList = Array.new #Initialize an empty array for the elections
      #for raw_election in raw_elections_list['elections'] #For each election received from the server
      #  election = Election.rest_to_election(raw_election.to_json) #Turn a elections in json format to a election object
      #  electionsList << election #Add it to the elections array
      #end
      
      total_elections = 1 #We only have one election
      total_pages = 1 #Therefore we only have one page
      electionsList = Array.new #Initialize an empty array for the elections
      for raw_election in raw_elections_list #For each election received from the server
        election = Election.rest_to_election(raw_election.to_json) #Turn a elections in json format to a election object
        electionsList << election #Add it to the elections array
      end
      
      return true, electionsList, total_elections, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end

  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Election object
  Param 1: Raw object
  Return 1: Transformed Election object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_election(rest_body)
    raw_election = JSON.parse(rest_body) #Turn the object to JSON to be able to manipulate it
      election = Election.new(
        id: raw_election["electionId"],
        title: raw_election["title"], 
        start_date: Util.epoch_to_date(raw_election["start"]), #Turn the epoch time to a string start_date, format defined by the locale parameter
        end_date: Util.epoch_to_date(raw_election["end"]), #Turn the epoch time to a string end_date, format defined by the locale parameter
        start_voting_date: Util.epoch_to_date(raw_election["startVoting"]), #Turn the epoch time to a string start_voting_date, format defined by the locale parameter
        end_voting_date: Util.epoch_to_date(raw_election["endVoting"]), #Turn the epoch time to a string end_voting_date, format defined by the locale parameter
        institution_id: raw_election["institutionId"],
        introduction: raw_election["introduction"],
        process: raw_election["process"])  
      return election #Return the transformed object
  end

end