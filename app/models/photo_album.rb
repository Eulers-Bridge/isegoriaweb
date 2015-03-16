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
    @creator_id = attributes[:creator_id]
    @owner_id = attributes[:owner_id]
    if !attributes[:created].blank?
      @created = attributes[:created]#milliseconds passed since epoch Jan/1/1970
    else
      @created = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))
    end
    @modified = Util.date_to_epoch(Time.now.strftime(I18n.t(:date_format_ruby)))

  end

  def save (user)
    Rails.logger.debug "Call to photoAlbum.save"
    if self.valid?
      Rails.logger.debug "The photo album is valid!"
      thumbnail = self.thumbnail
      if !thumbnail.blank?
        file_s3_path = Util.upload_image(@@images_directory,thumbnail)
      else
        file_s3_path = nil
      end
      photo_album_req = {'name'=>self.title,
                'description'=>self.description,
                'location'=>self.location,
                'created'=> self.created,
                'modified'=> self.modified,
                'creatorId'=> self.creator_id,
                'ownerId'=> self.owner_id,
                'thumbNailUrl'=>[file_s3_path]        
                }

      reqUrl = "/api/photoAlbum/"
      rest_response = MwHttpRequest.http_post_request(reqUrl,photo_album_req,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200" || rest_response.code == "201" || rest_response.code == "202"
        photo_album = rest_to_photo_album(rest_response.body)
        return true, photo_album
      else
        return false, "#{rest_response.code} #{rest_response.message}"
      end
    else
      Rails.logger.debug self.errors.full_messages
      return false, self.errors.full_messages
    end
  end

def update_attributes(attributes = {},user)
    if self.valid?
      Rails.logger.debug "The photo album is valid!"
      thumbnail = self.thumbnail
      if !@thumbnail.blank?
        file_s3_path = Util.upload_image(@@images_directory,thumbnail)
        if !attributes[:previous_thumbnail].blank?
          Util.delete_image(attributes[:previous_thumbnail])
        end
      else
        file_s3_path = self.thumbnail
      end
      photoAlbum = {'name'=>attributes[:name],
                'description'=>attributes[:description],
                'location'=>attributes[:location],
                'created'=> self.created,
                'modified'=> self.modified,
                'creatorId'=> self.creator_id,
                'ownerId'=> self.owner_id,
                'thumbNailUrl'=>[file_s3_path]        
                }
      reqUrl = "/api/photoAlbum/#{self.id}"

      rest_response = MwHttpRequest.http_put_request(reqUrl,photoAlbum,user['email'],user['password'])
      Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
      if rest_response.code == "200"
        return true, @rest_response
      else
        return false, "#{rest_response.code} #{rest_response.message}"
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
    rest_response = MwHttpRequest.http_delete_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == "200"
      return true, @rest_response
    else
      return false, "#{rest_response.code} #{rest_response.message}"
    end
  end

  def self.all(user, page)
    institutionId = user['institutionId']
    page = page != nil ? page : 0 
    Rails.logger.debug user
    reqUrl = "/api/photoAlbums/#{user['id']}"
    rest_response = MwHttpRequest.http_get_request(reqUrl,user['email'],user['password'])
    Rails.logger.debug "Response from server: #{rest_response.code} #{rest_response.message}: #{rest_response.body}"
    if rest_response.code == '200'
      raw_photo_albums_list = JSON.parse(rest_response.body)
      total_photo_albums = raw_photo_albums_list['totalAlbums']
      total_pages = raw_photo_albums_list['totalPages']
      photo_albums_list = Array.new
      for raw_photo_album in raw_photo_albums_list['albums']
        photo_album = rest_to_photo_album(raw_photo_album.to_json)
        photo_albums_list << photo_album
      end
      return true, photo_albums_list, total_photo_albums, total_pages
    else
      return false, "#{rest_response.code}", "#{rest_response.message}"
    end
  end

  def self.find(id)
  photo =  Photo.new(
      id: id, 
      title: "Test Title", 
      description: "Test Description", 
      path: "chuta", 
      alter_text: "Test Alter Text"
  )
  end

  private
  def self.rest_to_photo_album(rest_body)
    raw_photo_album = JSON.parse(rest_body)
    photo_album = PhotoAlbum.new(
      id: raw_photo_album["nodeId"], 
      title: raw_photo_album["name"], 
      content: raw_photo_album["description"], 
      thumbnail: album["thumbNailUrl"], 
      creator_email: raw_photo_album["created"], 
      date: raw_photo_album["modified"],
      student_year: raw_photo_album["creatorId"],
      _links: raw_photo_album["ownerId"])  
    return photo_album    
  end

end