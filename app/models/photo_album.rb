class PhotoAlbum
  include ActiveModel::Model

  attr_accessor :name, :description, :location, :thumbnail, :creator_id, :owner_id, :previous_thumbnail
  attr_reader :id, :created, :modified
  @@images_directory = "UniversityOfMelbourne/PhotoAlbums"
  @@thumbnails_folder ="/ThumbNails"

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :location, :presence => { :message => ApplicationHelper.validation_error(:location, :presence, nil) }

=begin
--------------------------------------------------------------------------------------------------------------------
  Photo Albums object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @location = attributes[:location]
    @thumbnail = attributes[:thumbnail]
    @creator_id = attributes[:creator_id]
    @owner_id = attributes[:owner_id]
    @previous_thumbnail = attributes[:previous_thumbnail]
    if !attributes[:created].blank?
      @created = attributes[:created]#milliseconds passed since epoch Jan/1/1970
    else
      @created = Time.now.strftime(I18n.t(:date_format_ruby))
    end
    @modified = Time.now.strftime(I18n.t(:date_format_ruby))
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Photo Album
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created photo album object
                        3.photo album creation status
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save(user)  
    Rails.logger.debug "Call to photo_album.save"
    if self.valid? #Validate if the Photo Album object is valid
      Rails.logger.debug "The photo album is valid!"

      file = self.thumbnail
      if !file.blank? #Validate if any image file was provided by the user
        file_s3_path = Util.upload_image(@@images_directory+@@thumbnails_folder,file) #Upload the new file to the server
      else
        file_s3_path = nil
      end
      #Create a raw photo album object
      photo_album_req = {'name'=>self.name,
        'description'=>self.description,
        'location'=>self.location,
        'thumbNailUrl'=>file_s3_path,
        'created'=> Util.date_to_epoch(self.created), #Turn the created to epoch
        'modified'=> Util.date_to_epoch(self.modified), #Turn the modified to epoch
        'creatorId'=> self.creator_id,
        'ownerId'=> self.owner_id       
      }

      reqUrl = "/api/photoAlbum/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,photo_album_req,user['email'],user['password']) #Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        photo_album = PhotoAlbum.rest_to_photo_album(rest_response.body) #Turn the response object to a PhotoAlbum object
        return true, photo_album #Return success
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
  Function to delete a Photo Album
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
    Rails.logger.debug "Call to photo_album.delete"
    if self.thumbnail.blank? #Check if there are a thumbnail related to the photo album
      Util.delete_image(self.thumbnail)#Delete the entire image folder related to the article
    end
    Util.delete_image_folder(@@images_directory,self.id.to_s)#Delete the entire image folder related to the photo album
    

    reqUrl = "/api/photoAlbum/#{self.id}" #Set the request url
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
  Function to update a Photo Album
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated photo album object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {},user)
    Rails.logger.debug "Call to photo_album.update_attributes"
    if self.valid? #Validate if the Photo album object is valid
      Rails.logger.debug "The photo album album is valid!"
      file = attributes[:thumbnail]#Set the photo album file object
      if !file.blank? #Validate if a file was supplied by the user
        file_s3_path = Util.upload_image(@@images_directory+@@thumbnails_folder,file) #Upload the new image
        if !attributes[:previous_thumbnail].blank? #Validate if there was a previous image file tied to the photo node
          Util.delete_image(attributes[:previous_thumbnail]) #Delete the previous image file
        end
      else
        file_s3_path = self.thumbnail #If none was provided, keep the original file
      end
      #Create a raw photo object
      photo_album_req = {'name'=>attributes[:name],
                'description'=>attributes[:description],
                'location'=>attributes[:location],
                'created'=> Util.date_to_epoch(self.created),
                'modified'=> Util.date_to_epoch(self.modified),
                'creatorId'=> self.creator_id,
                'ownerId'=> self.owner_id,
                'thumbNailUrl'=>file_s3_path        
                }        
      reqUrl = "/api/photoAlbum/#{self.id}" #Set the request url

      rest_response = MwHttpRequest.http_put_request(reqUrl,photo_album_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        photo_album = PhotoAlbum.rest_to_photo_album(rest_response.body)
        return true, photo_album #Return success
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
  Function to upload a picture for a Photo Album
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def upload_picture(attributes = {}, user)
    Rails.logger.debug "Call to photo_album.upload_picture"
    picture = attributes[:picture]#Get the picture object
    if !picture.blank?#Validate if the user supplied a picture
      #Create Photo node for Photo Album
      #Currently the wep app supports only one picture creation
      Rails.logger.debug 'Create Photo node for photo album: ' + self.id.to_s
      photo = Photo.new(
        title:self.name,
        description:self.name, 
        file:picture, 
        owner_id:self.id, 
        date:Time.now.strftime(I18n.t(:date_format_ruby)))
      resp = photo.save(user,@@images_directory+"/"+self.id.to_s)
      if resp[0]
        return true, resp[1]#Return sucess
      else
        return false, resp[1], resp[2] #Return error
      end
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the photo albums by its owner id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the photo album objects, 
                        3.total number of photo albums, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to photo_album.all"
    ownerId = user['id'] #Retrieve the owner id from the logged user
    page = page != nil ? page : 0  #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/photoAlbums/#{ownerId}?page=#{page}&pageSize=10" #Build the request url
    
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_photo_albums_list = JSON.parse(rest_response.body) #Get the photos info from the response and normalize it to an array to handle it
      total_photo_albums = raw_photo_albums_list['totalElements'] #Retrieve the total photo albums number for pagination
      total_pages = raw_photo_albums_list['totalPages'] #Retrieve the total number of pages for pagination
      photo_albums_list = Array.new #Initialize an empty array for the photo albums
      for raw_photo_album in raw_photo_albums_list['foundObjects'] #For each photo albums received from the server
        photo_album = PhotoAlbum.rest_to_photo_album(raw_photo_album.to_json) #Turn a photo album to json format 
        photo_albums_list << photo_album #Add it to the photo albums array
      end
      return true, photo_albums_list, total_photo_albums, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end
 
=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve an photo album by its id
  Param 1: photo album id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Photo album object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to photo_album.find"
    reqUrl = "/api/photoAlbum/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      photo_album = PhotoAlbum.rest_to_photo_album(rest_response.body) #Turn the response object to a Photo Album object
      return true, photo_album #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Photo Album object
  Param 1: Raw object
  Return 1: Transformed Photo Album object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_photo_album(rest_body)
    raw_photo_album = JSON.parse(rest_body)#Turn the object to an array to be able to manipulate it

    photo_album = PhotoAlbum.new(
      id: raw_photo_album["nodeId"], 
      name: raw_photo_album["name"], 
      description: raw_photo_album["description"],
      location: raw_photo_album["location"],
      thumbnail: raw_photo_album["thumbNailUrl"],  
      created: Util.epoch_to_date(raw_photo_album["created"]), #Turn the epoch time to a string created date, format defined by the locale parameter
      modified: Util.epoch_to_date(raw_photo_album["modified"]), #Turn the epoch time to a string modified date, format defined by the locale parameter
      creator_id: raw_photo_album["creatorId"],
      owner_id: raw_photo_album["ownerId"])  
    return photo_album #Return the transformed object     
  end

end