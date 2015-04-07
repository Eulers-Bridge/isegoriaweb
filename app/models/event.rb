class Event
include ActiveModel::Model

  attr_accessor :name, :start_date, :start_time, :end_date, :end_time, :location, :description, :picture, :volunteers, :organizer, :organizer_email, :institution_id
  attr_reader :id, :created, :modified
  @@images_directory = "UniversityOfMelbourne/Events"

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :start_date, :presence => { :message => ApplicationHelper.validation_error(:start_date, :presence, nil) }
  validates :end_date, :presence => { :message => ApplicationHelper.validation_error(:end_date, :presence, nil) }
  validates :location, :presence => { :message => ApplicationHelper.validation_error(:location, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :picture, :presence => { :message => ApplicationHelper.validation_error(:picture, :presence, nil) }
  validates :organizer, :presence => { :message => ApplicationHelper.validation_error(:organizer, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Event object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @start_date = attributes[:start_date]
    @start_time = attributes[:start_time]
    @end_date = attributes[:end_date]
    @end_time = attributes[:end_time]
    @location = attributes[:location]
    @description = attributes[:description]
    @picture = attributes[:picture]
    @volunteers = attributes[:volunteers]
    @organizer = attributes[:organizer]
    @organizer_email = attributes[:organizer_email]
    if !attributes[:created].blank?
      @created = attributes[:created]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    @modified = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Event
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created election object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save (user)
   Rails.logger.debug "Call to event.save"  
   if self.valid? #Validate if the event object is valid
      Rails.logger.debug "The event is valid!"
      picture = self.picture #Retrieve the picture object
      #Create a raw event object
      event_req = {
              'name'=>self.name,
              'starts'=>Util.datetime_to_epoch(self.start_date+" "+self.start_time),#Turn the start_date to epoch
              'ends'=>Util.datetime_to_epoch(self.end_date+" "+self.end_time), #Turn the end_date to epoch
              'location'=>self.location,
              'description'=>self.description,
              'volunteerPositions'=>nil,
              'organizer'=>self.organizer,
              'organizerEmail'=>self.organizer_email,
              'institutionId'=>user['institutionId'],
              'created'=>Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby))),#Turn the created_date to epoch
              'modified'=>Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))#Turn the modified_date to epoch
      }
      reqUrl = "/api/event/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,event_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        event = Event.rest_to_event(rest_response.body) #Turn the response object to an Article object
        if !picture.blank?#Validate if the user supplied a picture
          #Create Photo node for new event
          #Currently the wep app supports only one picture creation
          Rails.logger.debug 'Create Photo node for new event: ' + event.id.to_s
          photo = Photo.new(
            title:event.name,
            description:event.name, 
            file:picture, 
            owner_id:event.id, 
            date:Time.now.strftime(I18n.t(:date_format_ruby)))
          resp = photo.save(user,@@images_directory+"/"+event.id.to_s)#A new folder will be created for the event in the images server
          if !resp[0]
            return true, event, false #Return the notification that there was an error creating the picture node
          end
        end
        return true, event, true #Return success
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
  Function to delete an Event
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.server response
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  public
  def delete(user)
    Rails.logger.debug "Call to event.delete"
    photo_deletion = true #Initialize the photo deletion flag to true
    if self.picture.any? #Check if there are any photos related to the event
      for picture_obj in self.picture #Delete all photo nodes owned by the event
        photo = Photo.new(id:picture_obj["nodeId"])#Create the node object to delete
        resp_photo = photo.delete(user)#Delete the photo node
        if !resp_photo[0] #An error has ocurred when deleting photos
          photo_deletion = false #Set the photo deletion flag to false
        end
      end
      Util.delete_image_folder(@@images_directory,self.id.to_s)#Delete the entire image folder related to the event
    end
   
    if !photo_deletion #Validate if there were error when deleting photos
      return false, resp[1], resp[2] #Return error
    end

    reqUrl = "/api/event/#{self.id}" #Set the request url
    puts reqUrl
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
  Function to update an Event
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated event object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes={}, user)
    Rails.logger.debug "Call to event.update_attributes"
    if self.valid? #Validate if the Article object is valid
      Rails.logger.debug "The event is valid!"

      #Create a raw Article object
      event_req = {
              'name'=>attributes["name"],
              'starts'=>Util.datetime_to_epoch(attributes["start_date"]+" "+attributes["start_time"]),
              'ends'=>Util.datetime_to_epoch(attributes["end_date"]+" "+attributes["end_time"]),
              'location'=>attributes["location"],
              'description'=>attributes["description"],
              'volunteerPositions'=>nil,
              'organizer'=>attributes["organizer"],
              'organizerEmail'=>attributes["organizer_email"],
              'institutionId'=>user['institutionId'],
              'modified'=>Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
      }      
      reqUrl = "/api/event/#{self.id}" #Set the request url
      rest_response = MwHttpRequest.http_put_request(reqUrl,event_req,user['email'],user['password']) #Make the PUT request to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        event = Event.rest_to_event(rest_response.body)
        return true, event #Return success
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
  Function to upload a picture for an Event
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def upload_picture(attributes = {}, user)
    Rails.logger.debug "Call to event.upload_picture"
    picture = attributes[:picture]#Get the picture object
    if !picture.blank?#Validate if the user supplied a picture
      #Create Photo node for the event
      #Currently the wep app supports only one picture creation
      if attributes[:previous_picture].blank? #If no previous picture exists, then a new photo node is created
        Rails.logger.debug 'Create Photo node for event: ' + self.id.to_s
        photo = Photo.new(
          title:self.name,
          description:self.name, 
          file:picture, 
          owner_id:self.id, 
          date:Time.now.strftime(I18n.t(:date_format_ruby)))
        resp = photo.save(user,@@images_directory+"/"+self.id.to_s)
      else #Otherwise the picture node must be updated
        previous_picture = JSON.parse(attributes[:previous_picture])#Parse the previous picture object
        Rails.logger.debug 'Update Photo node for event: ' + self.id.to_s
        photo = Photo.new(
          id:previous_picture['nodeId'],
          title:self.name,
          description:self.name, 
          file:picture, 
          owner_id:self.id, 
          date:Time.now.strftime(I18n.t(:date_format_ruby)))
        resp = photo.update_photo_node(user,@@images_directory+"/"+self.id.to_s, previous_picture['url'])
      end
      if resp[0]
        return true, resp[1]#Return sucess
      else
        return false, resp[1], resp[2] #Return error
      end
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the events by its owner id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the event objects, 
                        3.total number of events, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to events.all"
    institutionId = user['institutionId'] #Retrieve the owner id from the logged user
    page = page != nil ? page : 0 #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/events/#{institutionId}?page=#{page}&pageSize=10" #Build the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_events_list = JSON.parse(rest_response.body) #Get the event info from the response and normalize it to an array to handle it
      total_events = raw_events_list['totalEvents'] #Retrieve the total events number for pagination
      total_pages = raw_events_list['totalPages'] #Retrieve the total number of pages for pagination
      events_list = Array.new #Initialize an empty array for the events
      for raw_event in raw_events_list['events'] #For each event received from the server
        events_list << event = Event.rest_to_event(raw_event.to_json) #Turn an event to json format and add it to the events array
      end
      return true, events_list, total_events, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve an event by its id
  Param 1: event id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Event object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to event.find"
    reqUrl = "/api/event/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      event = Event.rest_to_event(rest_response.body) #Turn the response object to an Event object
      return true, event #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}"#Return error
    end
  end
=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to an Event object
  Param 1: Raw object
  Return 1: Transformed Event object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_event(rest_body)
    raw_event = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      if raw_event["photos"].blank?
        picture = []
      else
        raw_pictures = raw_event["photos"]
        picture=JSON.parse(raw_pictures.to_json)
      end
      event = Event.new(
        id: raw_event["eventId"], 
        name: raw_event["name"],
        start_date: Util.epoch_to_date(raw_event["starts"]), #Turn the epoch date to a string date, format defined by the locale parameter
        end_date: Util.epoch_to_date(raw_event["ends"]), #Turn the epoch date to a string date, format defined by the locale parameter
        start_time: Util.epoch_get_time(raw_event["starts"]),#Turn the epoch time to a string time, format defined by the locale parameter,
        end_time: Util.epoch_get_time(raw_event["ends"]),#Turn the epoch time to a string time, format defined by the locale parameter
        location: Location.new(name:raw_event["location"],latitude: -37.7963,longitude: 144.9614),
        description: raw_event["description"], 
        picture: picture, 
        volunteers:[],
        #volunteers:[Volunteer.new(position_title: "Helper 11", description: "The first one that helps11"),Volunteer.new(position_title: "Helper 12", description: "The second one that helps12")]
        organizer: raw_event["organizer"],
        organizer_email: raw_event["organizerEmail"],
        institution_id: raw_event["institutionId"],
        created: Util.epoch_to_date(raw_event["created"]),#Turn the epoch date to a string date, format defined by the locale parameter
        modified: Util.epoch_to_date(raw_event["modified"])) #Turn the epoch date to a string date, format defined by the locale parameter
      return event  #Return the transformed object   
  end
end