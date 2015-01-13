class PhotoAlbum
  include ActiveModel::Model

  attr_accessor :name, :description, :location, :thumbnail, :creator_id, :owner_id
  attr_reader :id, :created, :modified
  @@images_directory = "UniversityOfMelbourne/PhotoAlbum"

  validates :name, :presence => { :message => ApplicationHelper.validation_error(:name, :presence, nil) }
  validates :description, :presence => { :message => ApplicationHelper.validation_error(:description, :presence, nil) }
  validates :location, :presence => { :message => ApplicationHelper.validation_error(:location, :presence, nil) }

  def initialize (attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @location = attributes[:location]
    @thumbnail = attributes[:thumbnail]
    if !attributes[:created].blank?
      @created = attributes[:created]#milliseconds passed since epoch Jan/1/1970
    else
      @created = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    @modified = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    if !attributes[:creator_id].blank?
      @creator_id = attributes[:creator_id]
    else
      @creator_id = "test_creator@eulersbridge.com"
    end
    if !attributes[:owner_id].blank?
      @owner_id = attributes[:owner_id]
    else
      @owner_id = "test_owner@eulersbridge.com"
    end
  end

  def save (user)
    if self.valid?
      Rails.logger.debug "The photo album is valid!"
      @thumbnail = self.thumbnail
      if !@thumbnail.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@thumbnail)
      else
        @file_s3_path = nil
      end
      photoAlbum = {'name'=>self.title,
                'description'=>self.description,
                'location'=>self.location,
                'created'=> self.created,
                'modified'=> self.modified,
                'creatorId'=> self.creator_id,
                'ownerId'=> self.owner_id,
                'thumbNailUrl'=>[@file_s3_path]        
                }

      reqUrl = "/api/photoAlbum/"
      @rest_response = MwHttpRequest.http_post_request(reqUrl,photoAlbum,user['email'],user['password'])
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

def update_attributes(attributes = {},user)
    if self.valid?
      Rails.logger.debug "The photo album is valid!"
      @thumbnail = self.thumbnail
      if !@thumbnail.blank?
        @file_s3_path = Util.upload_image(@@images_directory,@thumbnail)
        if !attributes[:previous_thumbnail].blank?
          Util.delete_image(attributes[:previous_thumbnail])
        end
      else
        @file_s3_path = self.thumbnail
      end
      photoAlbum = {'name'=>attributes[:name],
                'description'=>attributes[:description],
                'location'=>attributes[:location],
                'created'=> self.created,
                'modified'=> self.modified,
                'creatorId'=> self.creator_id,
                'ownerId'=> self.owner_id,
                'thumbNailUrl'=>[@file_s3_path]        
                }
      reqUrl = "/api/photoAlbum/#{self.id}"

      @rest_response = MwHttpRequest.http_put_request(reqUrl,photoAlbum,user['email'],user['password'])
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
  
  def delete(user)
    if !self.thumbnail.blank?
     Util.delete_image(self.thumbnail)
    end
    reqUrl = "/api/photoAlbum/#{self.id}"
    puts reqUrl
    @rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == "200"
      return true, @rest_response
    else
      return false, "#{@rest_response.code} #{@rest_response.message}"
    end
  end

  def self.all(user, page)
    @institutionId = user['institutionId']
    @page = page != nil ? page : 0 
    #reqUrl = "/api/photoAlbums/#{@institutionId}?page=#{@page}&pageSize=10"
    reqUrl = "/api/photoAlbums/"
    @rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{@rest_response.code} #{@rest_response.message}: #{@rest_response.body}"
    if @rest_response.code == '200'
      @raw_photo_albums_list = JSON.parse(@rest_response.body)
      @total_photo_albums = @raw_photo_albums_list['totalAlbums']
      @total_pages = @raw_photo_albums_list['totalPages']
      @photo_albums_list = Array.new
      for photo_album in @raw_photo_albums_list['albums']
        if photo_album["thumbNailUrl"].blank?
          @thumbnail = Util.get_image_server+@@images_directory+'/generic_thumbnail.png'
        else
          @thumbnail = album["thumbNailUrl"][0]
        end
        @photo_albums_list << PhotoAlbum.new(
        id: article["nodeId"], 
        title: article["name"], 
        content: article["description"], 
        thumbnail: @thumbnail, 
        creator_email: article["created"], 
        date: article["modified"],
        student_year: article["creatorId"],
        _links: article["ownerId"])
      end
      return true, @photo_albums_list, @total_photo_albums, @total_pages
    else
      return false, "#{@rest_response.code}", "#{@rest_response.message}"
    end
  end

  def self.find(id)
  @photo =  Photo.new(
      id: id, 
      title: "Test Title", 
      description: "Test Description", 
      path: "chuta", 
      alter_text: "Test Alter Text"
  )
  end

end