class Photo
  include ActiveModel::Model
  require 'json'

  attr_accessor :title, :description, :file, :date, :owner_id
  attr_reader :id
  @@images_directory = "UniversityOfMelbourne/Photos"

  validates :title, :presence => { :message => ApplicationHelper.validation_error(:title, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :file, :presence => { :message => ApplicationHelper.validation_error(:file, :presence, nil) }
  validates :date, :presence => { :message => ApplicationHelper.validation_error(:date, :presence, nil) }
  validates :owner_id, :presence => { :message => ApplicationHelper.validation_error(:owner_id, :presence, nil) }
  
=begin
--------------------------------------------------------------------------------------------------------------------
  Photo object constructor
--------------------------------------------------------------------------------------------------------------------
=end
  def initialize (attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @description = attributes[:description]
    @file = attributes[:file]
    @owner_id = attributes[:owner_id]
    if !attributes[:date].blank?
      @date = attributes[:date]#milliseconds passed since epoch Jan/1/1970
    else
      @date = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to create a new Photo
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.created photo object
                        3.photo creation status
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def save (user,images_directory) 
    Rails.logger.debug "Call to photo.save"
    if self.valid? #Validate if the photo object is valid
      Rails.logger.debug "The photo is valid!"
      
      file = self.file
      if !file.blank? #Validate if any image file was provided by the user
        images_directory=images_directory.blank? ? @@images_directory : images_directory #Validate if an image_directory was supplied, otherwise we use the default one
        file_s3_path = Util.upload_image(images_directory,file) #Upload the new file to the server
      else
        file_s3_path = nil
      end
      photo_req = { 'title'=>self.title,
                'description'=>self.description,
                'url'=>file_s3_path,
                'date'=> Util.date_to_epoch(self.date),#Turn the date to epoch
                'ownerId'=> self.owner_id         
                }
      reqUrl = "/api/photo/" #Set the request url
      rest_response = MwHttpRequest.http_post_request(reqUrl,photo_req,user['email'],user['password'])#Make the POST call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202" #Validate if the response from the server is satisfactory
        photo = Photo.rest_to_photo(rest_response.body) #Turn the response object to a Photo object
        return true, photo #Return success
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
  Function to delete a Photo
  Param 1: logged user object
  Return if successful: 1.execution result(true), 
                        2.response from the server
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def delete(user)
    Rails.logger.debug "Call to photo.delete"
    if !self.file.blank?
     Util.delete_image(self.file) #Delete the image file from the image server
    end
    reqUrl = "/api/photo/#{self.id}" #Set the request url
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])#Make the DELETE request to the server with the required parameters
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
      return true, rest_response #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to update a Photo
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated photo object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_attributes(attributes = {},user,images_directory)
    Rails.logger.debug "Call to photo.update_attributes"
    if self.valid? #Validate if the Photo object is valid
      Rails.logger.debug "The photo is valid!"
      file = attributes[:file]#Set the photo file object
      if !file.blank? #Validate if a file was supplied by the user
       images_directory =images_directory.blank? ? @@images_directory : images_directory #Validate if an image_directory was supplied, otherwise we use the default one
        file_s3_path = Util.upload_image(images_directory,file) #Upload the new image
        if !attributes[:previous_picture].blank? #Validate if there was a previous image file tied to the photo node
          Util.delete_image(attributes[:previous_picture]) #Delete the previous image file
        end
      else
        file_s3_path = self.file #If none was provided, keep the original file
      end
      #Create a raw photo object
      photo_req = { 'title'=>attributes[:title],
                'description'=>attributes[:description],
                'url'=>file_s3_path,
                'date'=> Util.date_to_epoch(attributes[:date]), #Turn the date to epoch
                'ownerId'=> self.owner_id         
                }        
      reqUrl = "/api/photo/#{self.id}" #Set the request url

      rest_response = MwHttpRequest.http_put_request(reqUrl,photo_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        photo = Photo.rest_to_photo(rest_response.body)
        return true, photo #Return success
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
  Function to update a Photo node affecting only the image file tied to it
  Param 1: attributes to update
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.updated photo object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def update_photo_node(user,images_directory,previous_picture)
    Rails.logger.debug "Call to photo.update_node"
    if self.valid? #Validate if the Photo object is valid
      Rails.logger.debug "The photo is valid!"
      file = self.file #Set the photo file object
      if !file.blank? #Validate if a file was supplied by the user
        images_directory =images_directory.blank? ? @@images_directory : images_directory #Validate if an image_directory was supplied, otherwise we use the default one
        file_s3_path = Util.upload_image(images_directory,file) #Upload the new image
        if !previous_picture.blank?#Validate if there was a previous image file tied to the photo node
          Util.delete_image(previous_picture) #Delete the previous image file
        end
      else
        file_s3_path = self.file #If none was provided, keep the original file
      end
      #Create a raw photo object
      photo_req = { 'title'=>self.title,
                'description'=>self.description,
                'url'=>file_s3_path,
                'date'=> Util.date_to_epoch(self.date), #Turn the date to epoch
                'ownerId'=> self.owner_id         
                }        
      reqUrl = "/api/photo/#{self.id}" #Set the request url

      rest_response = MwHttpRequest.http_put_request(reqUrl,photo_req,user['email'],user['password']) #Make the PUT call to the server with the required parameters
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" #Validate if the response from the server is 200, which means OK
        photo = Photo.rest_to_photo(rest_response.body)
        return true, photo #Return success
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
  Function to retrieve all the photos by its owner id
  Param 1: logged user object
  Param 2: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the photo objects, 
                        3.total number of photos, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all(user, page)
    Rails.logger.debug "Call to photo.all"
    ownerId = user['id'] #Retrieve the owner id from the logged user
    page = page != nil ? page : 0  #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/photos/#{ownerId}?page=#{page}&pageSize=10" #Build the request url
    
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_photos_list = JSON.parse(rest_response.body) #Get the photos info from the response and normalize it to an array to handle it
      total_photos = raw_photos_list['totalPhotos'] #Retrieve the total photos number for pagination
      total_pages = raw_photos_list['totalPages'] #Retrieve the total number of pages for pagination
      photos_list = Array.new #Initialize an empty array for the photos
      for raw_photo in raw_photos_list['photos'] #For each photo received from the server
        photo = Photo.rest_to_photo(raw_photo.to_json) #Turn a photo to json format 
        photos_list << photo #Add it to the photos array
      end
      return true, photos_list, total_photos, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve all the photos by its photo album id
  Param 1: logged user object
  Param 2: photo album id
  Param 3: number of page requested(pagination)
  Return if successful: 1.execution result(true), 
                        2.array with the photo objects, 
                        3.total number of photos, 
                        4.total number of pages
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, 
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.all_by_album(user,album_id,page)
    Rails.logger.debug "Call to photo.all_by_album"
    ownerId = album_id #Retrieve the owner id from the logged user
    page = page != nil ? page : 0  #If not page is sent as parameter, set it to the first page
    reqUrl = "/api/photos/#{ownerId}?page=#{page}&pageSize=10" #Build the request url
    
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      raw_photos_list = JSON.parse(rest_response.body) #Get the photos info from the response and normalize it to an array to handle it
      total_photos = raw_photos_list['totalPhotos'] #Retrieve the total photos number for pagination
      total_pages = raw_photos_list['totalPages'] #Retrieve the total number of pages for pagination
      photos_list = Array.new #Initialize an empty array for the photos
      for raw_photo in raw_photos_list['photos'] #For each photo received from the server
        photo = Photo.rest_to_photo(raw_photo.to_json) #Turn a photo to json format 
        photos_list << photo #Add it to the photos array
      end
      return true, photos_list, total_photos, total_pages #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to retrieve a photo by its id
  Param 1: photo id
  Param 2: logged user object
  Return if successful: 1.execution result(true), 
                        2.Photo object
  Return if unsuccessful: 1.execution result(false), 
                          2.response code from the server, or array of validation errors
                          3.response message from the server
--------------------------------------------------------------------------------------------------------------------
=end
  def self.find(id,user)
    Rails.logger.debug "Call to photo.find"
    reqUrl = "/api/photo/#{id}" #Set the request url

    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password']) #Make the GET request to the Middleware server
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200' #Validate if the response from the server is 200, which means OK
      photo = Photo.rest_to_photo(rest_response.body) #Turn the response object to a Photo object
      return true, photo #Return success
    else
      return false, "#{rest_response.code}", "#{rest_response.message}" #Return error
    end
  end

=begin
--------------------------------------------------------------------------------------------------------------------
  Function to transform the raw object received from the middleware to a Photo object
  Param 1: Raw object
  Return 1: Transformed Photo object
--------------------------------------------------------------------------------------------------------------------
=end
  private
  def self.rest_to_photo(rest_body)
    raw_photo = JSON.parse(rest_body) #Turn the object to an array to be able to manipulate it
      if raw_photo["url"].blank?
        file = nil
      else
        file = raw_photo["url"]
      end
      photo = Photo.new(
        id: raw_photo["nodeId"], 
        title: raw_photo["title"], 
        description: raw_photo["description"], 
        file: file, 
        owner_id:raw_photo["ownerId"], 
        date: Util.epoch_to_date(raw_photo["date"])) #Turn the epoch time to a string date, format defined by the locale parameter  
      return photo #Return the transformed object
  end

end