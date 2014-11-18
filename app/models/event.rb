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

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @start_date = attributes[:start_date]
    @start_time = attributes[:start_time]
    @end_date = attributes[:end_date]
    @end_time = attributes[:end_time]
    if !attributes[:created].blank?
      @created = attributes[:created]#milliseconds passed since epoch Jan/1/1970
    else
      @created = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    @modified = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    @location = attributes[:location]
    @description = attributes[:description]
    @picture = attributes[:picture]
    @volunteers = attributes[:volunteers]
    @organizer = attributes[:organizer]
    @organizer_email = attributes[:organizer_email]
  end
 
  def save (user)  
   if self.valid?
      @picture = self.picture
      if !@picture.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@picture)
      else
        @file_s3_path = nil
      end
      event = {
              'name'=>self.name,
              'starts'=>Util.datetime_to_epoch(self.start_date+" "+self.start_time),
              'ends'=>Util.datetime_to_epoch(self.end_date+" "+self.end_time),
              'location'=>self.location,
              'description'=>self.description,
              'picture'=>[@file_s3_path],
              'volunteerPositions'=>nil,
              'organizer'=>self.organizer,
              'organizerEmail'=>self.organizer_email,
              'institutionId'=>26,#change to user institution
              'created'=>self.created,
              'modified'=>self.modified
      }
      reqUrl = "/api/event/"
      @rest_response = MwHttpRequest.http_post_request(reqUrl,event,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == "200" || @rest_response.code == "201" || @rest_response.code == "202"
        return true, @rest_response
      else
        return false, "#{@rest_response.code} #{@rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  def update_attributes(attributes={}, user)
    if self.valid?
      Rails.logger.debug "The event is valid!"
      @picture = attributes[:picture]
      if !@picture.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@picture)
        if !attributes[:previous_picture].blank?
          Util.delete_image(attributes[:previous_picture])
        end
      else
        @file_s3_path = self.picture
      end
      event = {
              'name'=>attributes["name"],
              'starts'=>Util.datetime_to_epoch(attributes["start_date"]+" "+attributes["start_time"]),
              'ends'=>Util.datetime_to_epoch(attributes["end_date"]+" "+attributes["end_time"]),
              'location'=>attributes["location"],
              'description'=>attributes["description"],
              'picture'=>[@file_s3_path],
              'volunteerPositions'=>nil,
              'organizer'=>attributes["organizer"],
              'organizerEmail'=>attributes["organizer_email"],
              'institutionId'=>26,#change to user institution
              'modified'=>self.modified
      }      
      reqUrl = "/api/event/#{self.id}"

      @rest_response = MwHttpRequest.http_put_request(reqUrl,event,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
      if @rest_response.code == "200"
        return true, @rest_response
      else
        return false, "#{@rest_response.code} #{@rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

  public
  def delete(user)
    if !self.picture.blank?
      Util.delete_image(self.picture[0])
    end
    reqUrl = "/api/event/#{self.id}"
    puts reqUrl
    @rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == "200"
      return true, @rest_response
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.find(id,user)
    reqUrl = "/api/event/#{id}"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_event = JSON.parse(@rest_response.body)
      if @raw_event["picture"].blank?
        @picture = [  ]
      else
        @picture = @raw_event["picture"]
      end
      @event = Event.new(
        id: @raw_event["eventId"], 
        name: @raw_event["name"],
        start_date: Util.epoch_to_date(@raw_event["starts"]),
        end_date: Util.epoch_to_date(@raw_event["ends"]),
        start_time: Util.epoch_get_time(@raw_event["starts"]),
        end_time: Util.epoch_get_time(@raw_event["ends"]),
        location: Location.new(name:@raw_event["location"],latitude: -37.7963,longitude: 144.9614),
        description: @raw_event["description"], 
        picture: @picture, 
        volunteers:[],
        #volunteers:[Volunteer.new(position_title: "Helper 11", description: "The first one that helps11"),Volunteer.new(position_title: "Helper 12", description: "The second one that helps12")]
        organizer: @raw_event["organizer"],
        organizer_email: @raw_event["organizerEmail"],
        institution_id: @raw_event["institutionId"],
        created: @raw_event["created"],
        modified: @raw_event["modified"])
      return true, @event
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.all(user, page)
    @institutionId = user['institutionId']
    @page = page != nil ? page : 0 
    reqUrl = "/api/events/#{@institutionId}?page=#{@page}&pageSize=10"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_events_list = JSON.parse(@rest_response.body)
      @total_events = @raw_events_list['totalEvents']
      @total_pages = @raw_events_list['totalPages']
      @events_list = Array.new
      for event in @raw_events_list['events']
        if event["picture"].blank?
          @picture = Util.get_image_server+@@images_directory+'/generic_event.png'
        else
          @picture = event["picture"][0]
        end
        @events_list << Event.new(
        id: event["eventId"], 
        name: event["name"], 
        start_date: event["starts"],
        end_date: event["ends"],  
        location: Location.new(name:event["location"],latitude: -37.7963,longitude: 144.9614),
        description: event["description"],
        picture: @picture,
        organizer: event["organizer"],
        organizer_email: event["organizerEmail"])
      end
      return true, @events_list, @total_events, @total_pages
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
  end
end